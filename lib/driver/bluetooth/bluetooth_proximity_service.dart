import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:logging/logging.dart';

import '../../../application/config/logger.dart';
import '../../domain/physical_proximity.dart';

const txPower = -59;

class BleProximityService {
  final UUID serviceUuid;

  final _beaconBroadcast = BeaconBroadcast();
  final _centralManager = CentralManager();
  final StreamController<LotusBeaconPhysicalHandshake> _proximityController =
      StreamController<LotusBeaconPhysicalHandshake>.broadcast();

  final Map<String, LotusBeaconPhysicalHandshake> _proximityData = {};
  Timer? _cycleTimer;
  bool _isAdvertising = false;
  int? _currentRpid;

  Stream<List<LotusBeaconPhysicalHandshake>> get proximityDataStream =>
      _proximityController.stream.map((_) => _proximityData.values.toList());

  Stream<LotusBeaconPhysicalHandshake> get proximityStream => _proximityController.stream;

  late final StreamSubscription _discoveredSubscription;
  late final StreamSubscription _stateChangedSubscription;

  BleProximityService({
    required String eventId,
  }) : serviceUuid = UUID.fromString(eventId) {
    _initBeacon();
    _initBleScanner();
  }

  Future<void> _initBeacon() async {
    logger.info('ServiceUUID: $serviceUuid');
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

  Future<void> startAdvertising(int eventUserIndex, int rpid) async {
    await _beaconBroadcast
        .setUUID(serviceUuid.toString())
        .setMajorId(eventUserIndex) // eventUserIndex用
        .setMinorId(rpid) // RPID用
        .setIdentifier('') // not needed but just required
        .setTransmissionPower(txPower)
        .start();

    logger.info('Started advertising with RPID: $rpid');
  }

  Future<void> startScanning() async {
    logger.info('Start scanning');
    await _centralManager.startDiscovery(serviceUUIDs: [serviceUuid]);
  }

  Future<void> startCycle(int eventUserIndex, int rpid) async {
    logger.info('BLE start cycle with RPID: $rpid');
    _currentRpid = rpid;
    _cycleTimer?.cancel();
    _cycleTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (_isAdvertising) {
        await stopAdvertising();
        await startScanning();
        _isAdvertising = false;
      } else {
        await stopScanning();
        if (_currentRpid != null) {
          await startAdvertising(eventUserIndex, _currentRpid!);
        }
        _isAdvertising = true;
      }
    });

    await stopAdvertising();

    // 初回は広告から開始
    await startAdvertising(eventUserIndex, rpid);
    await Future.delayed(const Duration(seconds: 2));
    await startScanning();
    _isAdvertising = true;
  }

  void _onDiscovered(DiscoveredEventArgs args) {
    if (args.advertisement.manufacturerSpecificData.isEmpty) {
      return;
    }
    if (args.rssi < 100) {
      return;
    }

    final manufacturerData = args.advertisement.manufacturerSpecificData[0].data.sublist(0);
    final serviceDatas = args.advertisement.serviceData;

    // Debug log raw data
    logger.fine('Discovered: (${args.peripheral.uuid}) serviceData: $serviceDatas');
    logger.fine(
      'Discovered: Raw manufacturer data (${manufacturerData.length} bytes): ${manufacturerData.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}',
    );

    // iBeaconパケットの検証
    // 標準的なiBeaconパケットは26または27バイト
    // (1A + FF + 4C00 + 02 + 15 + UUID(16) + Major(2) + Minor(2) + Power(1))
    if (manufacturerData.length != 26 && manufacturerData.length != 27) {
      logger.fine('Invalid iBeacon data length: ${manufacturerData.length} bytes (expected 26 or 27)');
      return;
    }

    // Apple社の企業識別子 (0x004C)
    if (manufacturerData[0] != 0x4C || manufacturerData[1] != 0x00) {
      logger.fine(
          'Invalid manufacturer ID: ${manufacturerData[0].toRadixString(16)}${manufacturerData[1].toRadixString(16)} (expected 4C00)');
      return;
    }

    // iBeacon識別子 (0x02, 0x15)
    if (manufacturerData[2] != 0x02 || manufacturerData[3] != 0x15) {
      logger.fine(
          'Invalid iBeacon identifier: ${manufacturerData[2].toRadixString(16)}${manufacturerData[3].toRadixString(16)} (expected 0215)');
      return;
    }

    try {
      // UUID: 4バイト目から16バイト分
      final uuid = _extractUuid(manufacturerData.sublist(4, 20));

      // Major: 20-21バイト目
      final major = (manufacturerData[20] << 8) + manufacturerData[21];

      // Minor: 22-23バイト目
      final minor = (manufacturerData[22] << 8) + manufacturerData[23];

      // Power: 24バイト目
      final txPower = manufacturerData[24].toSigned(8);

      final estimatedDistance = _estimateDistance(args.rssi, txPower);
      final distance = estimatedDistance < 0.5
          ? EstimatedDistance.immediate
          : estimatedDistance < 3.0
              ? EstimatedDistance.near
              : EstimatedDistance.far;

      final proximity = LotusBeaconPhysicalHandshake(
        beaconId: args.peripheral.uuid.value.toString(),
        distance: distance,
        estimatedDistance: estimatedDistance,
        txPower: txPower,
        rssi: args.rssi,
        lastDetectedAt: DateTime.now(),
        eventId: serviceUuid.toString(),
        userIndex: major.toString(),
        rpid: minor.toString(),
      );

      _proximityData[uuid] = proximity;
      _proximityController.add(proximity);
      logger.info('Discovered $proximity');
    } catch (e) {
      logger.severe('Error parsing iBeacon data: $e');
    }
  }

  String _extractUuid(List<int> data) {
    final buffer = StringBuffer();
    for (var i = 0; i < data.length; i++) {
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
    logger.info('🟥 BLE service disposed');
    _cycleTimer?.cancel();
    _beaconBroadcast.stop();
    _discoveredSubscription.cancel();
    _stateChangedSubscription.cancel();
    _proximityController.close();
  }
}
