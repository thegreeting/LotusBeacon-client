import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../driver/bluetooth/bluetooth_proximity_service.dart';
import '../../domain/physical_proximity.dart';

final bleServiceProvider = Provider((ref) => BleProximityService());

final rpidProvider = Provider((ref) => const Uuid().v4());

final proximityStreamProvider = StreamProvider<List<PhysicalProximity>>((ref) {
  final service = ref.watch(bleServiceProvider);
  return service.proximityStream
      .map((proximity) => [proximity])
      .startWith([]);
});
