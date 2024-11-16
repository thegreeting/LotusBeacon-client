import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/usecase/event_provider.dart';
import 'package:lotusbeacon/usecase/user_provider.dart';

import '../domain/physical_proximity.dart';
import '../driver/bluetooth/bluetooth_proximity_service.dart';
import 'rpid_provider.dart';

class RegistrationRequiredException implements Exception {
  const RegistrationRequiredException();
}

// 基本のBLEサービスプロバイダ
final bleServiceProvider = Provider((ref) {
  final event = ref.watch(selectedEventProvider);
  return BleProximityService(eventId: event.id);
});

// BLEサービスとRPIDを連携させるファサードプロバイダ
final bleServiceFacadeProvider = Provider((ref) {
  final service = ref.watch(bleServiceProvider);
  final eventUserIndex = ref.watch(currenEventUserIndexProvider);
  if (eventUserIndex == null) {
    throw const RegistrationRequiredException();
  }

  // RPIDの変更を監視してBLEサイクルを更新
  ref.listen(rpidProvider, (previous, next) {
    next.whenData((rpid) async {
      await service.startCycle(eventUserIndex, rpid);
    });
  });

  return service;
});

// プロキシメティストリームプロバイダ
final proximityStreamProvider = StreamProvider<List<LotusBeaconPhysicalHandshake>>((ref) {
  final service = ref.watch(bleServiceFacadeProvider);
  return service.proximityDataStream;
});
