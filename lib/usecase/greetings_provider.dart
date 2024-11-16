import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/domain/greeting.dart';

final greetingStatusProvider = FutureProvider.family<
    GreetingStatus,
    ({
      String eventId,
      String user1Id,
      String user2Id,
    })>((ref, params) async {
  // TODO(knaoe): To be impl.
  return GreetingStatus.none;
});

final greetingsProvider = StreamProvider.family<List<Greeting>, String>((ref, eventId) {
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});
