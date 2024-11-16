import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:logging/logging.dart';

import '../../../application/config/logger.dart';
import '../../domain/physical_proximity.dart';

class BleProximityService {
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

  BleProximityService()
      : _centralManager = CentralManager(),
        _peripheralManager = PeripheralManager() {
    hierarchicalLoggingEnabled = true;
    _centralManager.logLevel = Level.INFO;
    _peripheralManager.logLevel = Level.INFO;

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
    final advertisementName = '🪷 0 1 $rpid';
    await _peripheralManager.removeAllServices();

    await _peripheralManager.startAdvertising(
      Advertisement(
        name: Platform.isWindows ? null : advertisementName,
      ),
    );
    logger.info('Started advertising with name: $advertisementName');
  }

  Future<void> startScanning() async {
    logger.info('Start scanning');
    await _centralManager.startDiscovery(
        // serviceUUIDs: [serviceUuid],
        );
  }

  Future<void> startCycle(String rpid) async {
    _currentRpid = rpid;
    _cycleTimer?.cancel();
    _cycleTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
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
    final peripheral = args.peripheral;

    final advertisementName = args.advertisement.name;

    if (advertisementName != null && advertisementName.startsWith('🪷')) {
      logger.info('Discovered device: $advertisementName uuid: ${peripheral.uuid}, RSSI: ${args.rssi}');
      try {
        final List<String> advertiseData = advertisementName.split(' ').sublist(1);
        final String eventId = advertiseData[0];
        final String userIndex = advertiseData[1];
        final String rpid = advertiseData[2];

        final estimatedDistance = _estimateDistance(args.rssi);
        final distance = estimatedDistance > -58.0
            ? EstimatedDistance.immediate
            : estimatedDistance > -100.0
                ? EstimatedDistance.near
                : EstimatedDistance.far;

        final proximity = LotusBeaconPhysicalHandshake(
          beaconId: peripheral.uuid.value.toString(),
          rpid: rpid,
          distance: distance,
          estimatedDistance: _estimateDistance(args.rssi),
          rssi: args.rssi,
          lastDetectedAt: DateTime.now(),
          eventId: eventId,
          userIndex: userIndex,
        );
        // データを累積保持
        _proximityData[rpid] = proximity;
        _proximityController.add(proximity);
      } catch (e) {
        logger.severe('Error decoding data: $e of $advertisementName');
      }
    }
  }

  double _estimateDistance(int rssi) {
    // This is a very simple distance estimation.
    // You might want to use a more sophisticated algorithm based on your specific needs.
    return pow(10, (-69 - rssi) / (10 * 2)).toDouble();
  }

  Future<void> stopAdvertising() async {
    await _peripheralManager.stopAdvertising();
  }

  Future<void> stopScanning() async {
    await _centralManager.stopDiscovery();
  }

  void dispose() {
    _cycleTimer?.cancel();
    _discoveredSubscription.cancel();
    _stateChangedSubscription.cancel();
    _proximityController.close();
  }
}
