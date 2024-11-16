import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:logging/logging.dart';

import '../../../application/config/logger.dart';
import '../../domain/physical_proximity.dart';

class BleProximityService {
  final BeaconBroadcast _beaconBroadcast = BeaconBroadcast();
  static UUID serviceUuid = UUID.fromString('FFFF');

  final CentralManager _centralManager;
  final PeripheralManager _peripheralManager;
  final StreamController<LotusBeaconPhysicalHandshake> _proximityController =
      StreamController<LotusBeaconPhysicalHandshake>.broadcast();

  final Map<String, LotusBeaconPhysicalHandshake> _proximityData = {};
  Timer? _cycleTimer;
  bool _isAdvertising = false;
  String? _currentRpid;

  Stream<List<LotusBeaconPhysicalHandshake>> get proximityDataStream =>
      _proximityController.stream.map((_) => _proximityData.values.toList());

  Stream<LotusBeaconPhysicalHandshake> get proximityStream => _proximityController.stream;

  late final StreamSubscription _discoveredSubscription;
  late final StreamSubscription _stateChangedSubscription;

  BleProximityService() {
    _initBeacon();
    _initBleScanner();
  }

  Future<void> _initBeacon() async {
    final status = await _beaconBroadcast.checkTransmissionSupported();
    switch (status) {
      case BeaconStatus.supported:
        logger.info('Beacon transmission is supported');
        break;
      default:
        logger.severe('Beacon transmission is not supported: $status');
        break;
    }

    _beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
      logger.info('Beacon advertising state changed: $isAdvertising');
    });
  }

  void _initBleScanner() {
    _centralManager.logLevel = Level.INFO;
    _discoveredSubscription = _centralManager.discovered.listen(_onDiscovered);
    _stateChangedSubscription = _centralManager.stateChanged.listen(_onStateChanged);
  }

  void _onStateChanged(args) async {
    logger.info('BLE State changed: ${args.state}');
    if (args.state == BluetoothLowEnergyState.unauthorized && Platform.isAndroid) {
      await _centralManager.authorize();
    }
  }

  Future<void> startAdvertising(String rpid) async {
    await _beaconBroadcast
        .setUUID('39ED98FF-2900-441A-802F-9C398FC199D2')
        .setMajorId(0) // eventId用
        .setMinorId(1) // userIndex用
        .setIdentifier(rpid)
        .setTransmissionPower(-59)
        .start();
    
    logger.info('Started advertising with RPID: $rpid');
  }

  Future<void> startScanning() async {
    logger.info('Start scanning');
    await _centralManager.startDiscovery(
        // serviceUUIDs: [serviceUuid],
        );
  }

  Future<void> startCycle(String rpid) async {
    logger.info('BLE start cycle with RPID: $rpid');
    _currentRpid = rpid;
    _cycleTimer?.cancel();
    _cycleTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_isAdvertising) {
        await stopAdvertising();
        await startScanning();
        _isAdvertising = false;
      } else {
        await stopScanning();
        if (_currentRpid != null) {
          await startAdvertising(_currentRpid!);
        }
        _isAdvertising = true;
      }
    });

    // 初回は広告から開始
    await startAdvertising(rpid);
    _isAdvertising = true;
  }

  void _onDiscovered(DiscoveredEventArgs args) {
    if (args.advertisement.manufacturerData != null) {
      final data = args.advertisement.manufacturerData;
      // Parse iBeacon manufacturer data
      if (data != null && data.length >= 25 && data[0] == 0x4C && data[1] == 0x00) {
        try {
          final uuid = _extractUuid(data.sublist(4, 20));
          final major = (data[20] << 8) + data[21];
          final minor = (data[22] << 8) + data[23];
          final txPower = data[24].toSigned(8);

          final estimatedDistance = _estimateDistance(args.rssi, txPower);
          final distance = estimatedDistance < 0.5
              ? EstimatedDistance.immediate
              : estimatedDistance < 3.0
                  ? EstimatedDistance.near
                  : EstimatedDistance.far;

          final proximity = LotusBeaconPhysicalHandshake(
            beaconId: args.peripheral.uuid.value.toString(),
            rpid: uuid,
            distance: distance,
            estimatedDistance: estimatedDistance,
            rssi: args.rssi,
            lastDetectedAt: DateTime.now(),
            eventId: major.toString(),
            userIndex: minor.toString(),
          );

          _proximityData[uuid] = proximity;
          _proximityController.add(proximity);
        } catch (e) {
          logger.severe('Error parsing iBeacon data: $e');
        }
      }
    }
  }

  String _extractUuid(List<int> data) {
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(data[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString().toUpperCase();
  }

  double _estimateDistance(int rssi, int txPower) {
    if (rssi == 0) return -1.0;
    
    final ratio = rssi * 1.0 / txPower;
    if (ratio < 1.0) {
      return pow(ratio, 10).toDouble();
    }
    return (0.89976) * pow(ratio, 7.7095) + 0.111;
  }

  Future<void> stopAdvertising() async {
    await _beaconBroadcast.stop();
    logger.info('Stopped advertising');
  }

  Future<void> stopScanning() async {
    await _centralManager.stopDiscovery();
  }

  void dispose() {
    _cycleTimer?.cancel();
    _beaconBroadcast.stop();
    _discoveredSubscription.cancel();
    _stateChangedSubscription.cancel();
    _proximityController.close();
  }
}
