import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/physical_proximity.dart';
import '../driver/bluetooth/bluetooth_proximity_service.dart';
import 'rpid_provider.dart';

// 基本のBLEサービスプロバイダ
final bleServiceProvider = Provider((ref) => BleProximityService());

// BLEサービスとRPIDを連携させるファサードプロバイダ
final bleServiceFacadeProvider = Provider((ref) {
  final service = ref.watch(bleServiceProvider);
  
  // RPIDの変更を監視してBLEサイクルを更新
  ref.listen(rollingRpidProvider, (previous, next) {
    next.whenData((rpid) async {
      await service.startCycle(rpid);
    });
  });
  
  return service;
});

// プロキシメティストリームプロバイダ
final proximityStreamProvider = StreamProvider<List<LotusBeaconPhysicalHandshake>>((ref) {
  final service = ref.watch(bleServiceFacadeProvider);
  return service.proximityDataStream;
});
