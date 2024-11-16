// GreetingStatus.mutual
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/domain/participant.dart';
import 'package:lotusbeacon/usecase/auth_provider.dart';
import 'package:lotusbeacon/usecase/greetings_provider.dart';
import 'package:lotusbeacon/usecase/participants_provider.dart';
import 'package:lotusbeacon/usecase/user_provider.dart';

final meAndParticipantOnEventProvider =
    Provider.family<Participant?, ({String eventId, String participantUserId})>((ref, params) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return null;
  }

  final user = ref
      .watch(userProvider((
        eventId: 'eventId',
        userId: currentUserId,
      )))
      .asData
      ?.value;
  if (user == null) {
    throw Exception('User not found');
  }

  final greetingStatus = ref
      .watch(greetingStatusProvider(
        (
          eventId: params.eventId,
          user1Id: currentUserId,
          user2Id: params.participantUserId,
        ),
      ))
      .asData
      ?.value;
  if (greetingStatus == null) {
    throw Exception('GreetingStatus not found');
  }

  return Participant(
    user: user,
    greetingStatus: greetingStatus,
  );
});

final mutualGreetingParticipantUserIdOnEventProvider = StreamProvider.family<List<String>, String>((ref, eventId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return const Stream.empty();
  }
  final participantUserIds = ref.watch(participantUserIdsOnEventProvider(eventId));
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});

final sentGreetingParticipantUserIdOnEventProvider = StreamProvider.family<List<String>, String>((ref, eventId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return const Stream.empty();
  }
  final participantUserIds = ref.watch(participantUserIdsOnEventProvider(eventId));
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});

final receivedGreetingParticipantUserIdOnEventProvider = StreamProvider.family<List<String>, String>((ref, eventId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return const Stream.empty();
  }
  final participantUserIds = ref.watch(participantUserIdsOnEventProvider(eventId));
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});

final noneGreetingButNearByParticipantUserIdOnEventProvider =
    StreamProvider.family<List<String>, String>((ref, eventId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return const Stream.empty();
  }
  final participantUserIds = ref.watch(participantUserIdsOnEventProvider(eventId));
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});

final noneGreetingParticipantUserIdOnEventProvider = StreamProvider.family<List<String>, String>((ref, eventId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return const Stream.empty();
  }
  final participantUserIds = ref.watch(participantUserIdsOnEventProvider(eventId));
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});
