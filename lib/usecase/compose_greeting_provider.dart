import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/domain/physical_proximity.dart';
import 'package:lotusbeacon/domain/user.dart';

Future<void> composeGreeting({
  required WidgetRef ref,
  required String eventId,
  required User postUser,
  required User targetUser,
  required List<LotusBeaconPhysicalHandshake> handshakes,
  int numTokens = 1,
}) async {
  // TODO(knaoe): To be impl.
  return;
}
