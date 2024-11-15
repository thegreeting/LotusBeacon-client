import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

import '../../../application/config/logger.dart';
import '../../domain/physical_proximity.dart';

class BleProximityService {
  static UUID serviceUuid = UUID.fromString('4fafc201-1fb5-459e-8fcc-c5c9c331914b');

  final CentralManager _centralManager;
  final PeripheralManager _peripheralManager;
  final StreamController<PhysicalProximity> _proximityController = StreamController<PhysicalProximity>.broadcast();

  Stream<PhysicalProximity> get proximityStream => _proximityController.stream;

  late final StreamSubscription _discoveredSubscription;

  BleProximityService()
      : _centralManager = CentralManager(),
        _peripheralManager = PeripheralManager() {
    _discoveredSubscription = _centralManager.discovered.listen(_onDiscovered);
  }

  Future<void> startAdvertising(String rpid) async {
    final Map<String, dynamic> advertiseData = {
      'rpid': rpid,
    };
    final Uint8List data = utf8.encode(json.encode(advertiseData));

    final service = GATTService(
      uuid: UUID.short(100),
      isPrimary: true,
      includedServices: [],
      characteristics: [
        GATTCharacteristic.immutable(
          uuid: serviceUuid,
          value: data,
          descriptors: [],
        ),
        GATTCharacteristic.mutable(
          uuid: UUID.short(201),
          properties: [
            GATTCharacteristicProperty.read,
            GATTCharacteristicProperty.write,
            GATTCharacteristicProperty.writeWithoutResponse,
            GATTCharacteristicProperty.notify,
            GATTCharacteristicProperty.indicate,
          ],
          permissions: [
            GATTCharacteristicPermission.read,
            GATTCharacteristicPermission.write,
          ],
          descriptors: [],
        ),
      ],
    );

    await _peripheralManager.addService(service);
    await _peripheralManager.startAdvertising(
      Advertisement(
        name: Platform.isIOS || Platform.isMacOS ? 'LotusBeacon BLE Proximity' : null,
        serviceData: Platform.isIOS || Platform.isMacOS
            ? {}
            : {
                serviceUuid: data,
              },
      ),
    );
  }

  Future<void> startScanning() async {
    await _centralManager.startDiscovery(
      serviceUUIDs: [serviceUuid],
    );
  }

  void _onDiscovered(DiscoveredEventArgs args) {
    final peripheral = args.peripheral;
    final manufacturerData = args.advertisement.manufacturerSpecificData.firstOrNull?.data;

    if (manufacturerData != null) {
      try {
        final Map<String, dynamic> advertiseData = json.decode(utf8.decode(manufacturerData));

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
        logger.severe('Error decoding manufacturer data: $e');
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
    _proximityController.close();
  }
}
