import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/usecase/auth_provider.dart';

final participantUserIdsOnEventProvider = StreamProvider.family<List<String>, String>((
  ref,
  eventId,
) {
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});

// Soft participation means that the user has participated in the event, but confirmed by web2 not web3.
// We prefer web2 storage for user's participation status to improve the user experience.
// Using web3 in this case is too much.
final hasSoftParticipatedOnEventProvider = Provider.family<bool, String>((
  ref,
  eventId,
) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return false;
  }
  // TODO(knaoe): To be impl. fetch from remote web2 storage.
  return false;
});

Future<void> hasSoftRegisteredOnEvent({
  required String eventId,
  required String userId,
}) async {
  // TODO(knaoe): fetch from remote web2 storage.
  return;
}

Future<void> participateUserOnEventOrHardRegisterIfNeeded({
  required String eventId,
  required String userId,
}) async {
  // TODO(knaoe): call to Contract to get eventUserIndex

  // TODO(knaoe): call to Contract to register user on event to issue eventUserIndex if not registered

  // TODO(knaoe): update web2 storage. profile

  // TODO(knaoe): update web2 storage. event.participants
}

// Future<void> unparticipateUserOnEventOrHardUnregisterIfNeeded({
//   required String eventId,
//   required String userId,
// }) async {
//   // TODO(knaoe): call to Contract to get eventUserIndex

//   // TODO(knaoe): call to Contract to unregister user on event if registered

//   // TODO(knaoe): update web2 storage. profile

//   // TODO(knaoe): update web2 storage. event.participants
// }
