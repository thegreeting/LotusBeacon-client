import 'dart:convert';
import 'dart:math' show Random, secure;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/config/logger.dart';

/// 16バイトのランダムなシード値を生成・保持するプロバイダー
final rpidSeedProvider = Provider<String>((ref) {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  return base64Url.encode(values);
});

/// 20秒ごとに更新されるRolling Proximity Identifier (RPID)を生成するプロバイダー
final rpidProvider = StreamProvider<int>((ref) {
  final seed = ref.watch(rpidSeedProvider);
  final usedRpids = <int, DateTime>{};  // Track RPIDs with their generation timestamp

  return Stream.periodic(const Duration(seconds: 5), (count) {
    final now = DateTime.now();
    final timeWindow = now.millisecondsSinceEpoch ~/ 20000;
    logger.info('RPID count: $count, timeWindow: $timeWindow');

    // Remove RPIDs older than 30 minutes
    usedRpids.removeWhere((_, timestamp) => 
      now.difference(timestamp).inMinutes >= 30);

    int rpid;
    do {
      // Modified RPID generation logic for more diverse values
      final input = utf8.encode('$seed:$timeWindow:$count:${Random().nextInt(10000)}');
      final hash = base64Url.encode(input);
      final rpidBytes = utf8.encode(hash).sublist(0, 2);
      rpid = (rpidBytes[0] << 8) + rpidBytes[1];
    } while (usedRpids.containsKey(rpid)); // Regenerate if RPID was already used

    usedRpids[rpid] = now;
    logger.fine('Generated RPID: $rpid (Total tracked RPIDs: ${usedRpids.length})');

    return rpid;
  }).distinct();
});
