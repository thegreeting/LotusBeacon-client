import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:logging/logging.dart';

import '../../../application/config/logger.dart';
import '../../domain/physical_proximity.dart';

class BleProximityService {
  static UUID serviceUuid = UUID.fromString('4fafc201-1fb5-459e-8fcc-c5c9c331914b');

  final CentralManager _centralManager;
  final PeripheralManager _peripheralManager;
  final StreamController<PhysicalProximity> _proximityController = StreamController<PhysicalProximity>.broadcast();

  Stream<PhysicalProximity> get proximityStream => _proximityController.stream;

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
    final Map<String, dynamic> advertiseData = {
      'rpid': rpid,
    };
    final Uint8List data = utf8.encode(json.encode(advertiseData));

    await _peripheralManager.removeAllServices();

    final service = GATTService(
      uuid: serviceUuid,
      isPrimary: true,
      includedServices: [],
      characteristics: [
        GATTCharacteristic.immutable(
          uuid: serviceUuid,
          value: data,
          descriptors: [],
        ),
      ],
    );

    await _peripheralManager.addService(service);
    await _peripheralManager.startAdvertising(
      Advertisement(
        name: Platform.isWindows ? null : 'LotusBeacon',
        manufacturerSpecificData: [
          if (Platform.isWindows || Platform.isAndroid)
            ManufacturerSpecificData(
              id: 0x2e19, // 任意のメーカーID
              data: data,
            ),
        ],
        serviceUUIDs: [serviceUuid],
      ),
    );
    logger.info('Started advertising with RPID: $rpid');
  }

  Future<void> startScanning() async {
    await _centralManager.startDiscovery(
      serviceUUIDs: [serviceUuid],
    );
  }

  void _onDiscovered(DiscoveredEventArgs args) {
    final peripheral = args.peripheral;
    logger.info('Discovered device: ${peripheral.uuid}, RSSI: ${args.rssi}');

    Uint8List? serviceData;
    if (Platform.isIOS || Platform.isMacOS) {
      // iOS/macOSの場合はサービスデータを確認
      serviceData = args.advertisement.serviceData[serviceUuid];
    } else {
      // AndroidではManufacturerDataを確認
      serviceData = args.advertisement.manufacturerSpecificData.firstOrNull?.data;
    }

    if (serviceData != null) {
      try {
        final Map<String, dynamic> advertiseData = json.decode(utf8.decode(serviceData));

        if (advertiseData.containsKey('rpid')) {
          final String rpid = advertiseData['rpid'];

          final estimatedDistance = _estimateDistance(args.rssi);
          final distance = estimatedDistance > -70.0
              ? EstimatedDistance.immediate
              : estimatedDistance > -100.0
                  ? EstimatedDistance.near
                  : EstimatedDistance.far;

          final PhysicalProximity proximity = PhysicalProximity(
            beaconId: peripheral.uuid.value.toString(),
            rpid: rpid,
            distance: distance,
            estimatedDistance: _estimateDistance(args.rssi),
            rssi: args.rssi,
            lastDetectedAt: DateTime.now(),
          );

          _proximityController.add(proximity);
        }
      } catch (e) {
        logger.severe('Error decoding data: $e');
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
    _discoveredSubscription.cancel();
    _stateChangedSubscription.cancel();
    _proximityController.close();
  }
}
