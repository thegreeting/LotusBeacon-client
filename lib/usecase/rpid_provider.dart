import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 16バイトのランダムなシード値を生成・保持するプロバイダー
final rpidSeedProvider = Provider<String>((ref) {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  return base64Url.encode(values);
});

/// 20秒ごとに更新されるRolling Proximity Identifier (RPID)を生成するプロバイダー
final rollingRpidProvider = StreamProvider<String>((ref) {
  final seed = ref.watch(rpidSeedProvider);

  // TODO(knaoe): 🔥 DEBUG later
  return Stream.periodic(const Duration(seconds: 20), (count) {
    // 現在の時間を20秒間隔で切り捨てて、タイムウィンドウの開始時刻を取得
    final timeWindow = DateTime.now().millisecondsSinceEpoch ~/ 20000;

    // シード値とタイムウィンドウを組み合わせてRPIDを生成
    final input = utf8.encode('$seed:$timeWindow');
    final hash = base64Url.encode(input);

    // 最初の16文字を使用してRPIDとする
    return hash.substring(0, 16);
  }).distinct(); // 同じ値は発行しない
});
