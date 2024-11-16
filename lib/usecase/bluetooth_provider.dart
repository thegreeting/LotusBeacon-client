import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/physical_proximity.dart';
import '../driver/bluetooth/bluetooth_proximity_service.dart';

final bleServiceProvider = Provider((ref) => BleProximityService());

final proximityStreamProvider = StreamProvider<List<LotusBeaconPhysicalHandshake>>((ref) {
  final service = ref.watch(bleServiceProvider);
  return service.proximityDataStream;
});
