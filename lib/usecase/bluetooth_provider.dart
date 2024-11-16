import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../domain/physical_proximity.dart';
import '../driver/bluetooth/bluetooth_proximity_service.dart';

final bleServiceProvider = Provider((ref) => BleProximityService());

final rpidProvider = Provider((ref) => const Uuid().v4());

final proximityStreamProvider = StreamProvider<List<LotusBeaconPhysicalHandshake>>((ref) {
  final service = ref.watch(bleServiceProvider);
  return service.proximityStream.map((proximity) => [proximity]).startWith([]);
});
