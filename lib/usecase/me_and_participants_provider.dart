import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/domain/greeting.dart';
import 'package:lotusbeacon/domain/participant.dart';
import 'package:lotusbeacon/usecase/auth_provider.dart';
import 'package:lotusbeacon/usecase/greetings_provider.dart';
import 'package:lotusbeacon/usecase/participants_provider.dart';
import 'package:lotusbeacon/usecase/user_provider.dart';

Participant? getParticipant(Ref ref, String eventId, String participantUserId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return null;
  }

  final user = ref
      .watch(userProvider((
        eventId: eventId,
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
          eventId: eventId,
          user1Id: currentUserId,
          user2Id: participantUserId,
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
}

final meAndParticipantOnEventProvider =
    Provider.family<Participant?, ({String eventId, String participantUserId})>((ref, params) {
  return getParticipant(ref, params.eventId, params.participantUserId);
});

Stream<List<Participant>> getParticipantsByGreetingStatus(Ref ref, String eventId, GreetingStatus status) async* {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    yield [];
    return;
  }
  final participantUserIds = ref.watch(participantUserIdsOnEventProvider(eventId)).asData?.value ?? [];

  final participants = <Participant>[];

  for (final participantUserId in participantUserIds) {
    final participant = ref.watch(meAndParticipantOnEventProvider(
      (
        eventId: eventId,
        participantUserId: participantUserId,
      ),
    ));
    if (participant == null) {
      throw Exception('Participant not found');
    }
    if (participant.greetingStatus == status) {
      participants.add(participant);
    }
  }

  yield participants;
}

final mutualGreetingParticipantOnEventProvider = StreamProvider.family<List<Participant>, String>((ref, eventId) {
  return getParticipantsByGreetingStatus(ref, eventId, GreetingStatus.mutual);
});

final sentGreetingParticipantUserIdOnEventProvider = StreamProvider.family<List<Participant>, String>((ref, eventId) {
  return getParticipantsByGreetingStatus(ref, eventId, GreetingStatus.sent);
});

final receivedGreetingParticipantUserIdOnEventProvider =
    StreamProvider.family<List<Participant>, String>((ref, eventId) {
  return getParticipantsByGreetingStatus(ref, eventId, GreetingStatus.received);
});

final noneGreetingButNearByParticipantUserIdOnEventProvider =
    StreamProvider.family<List<Participant>, String>((ref, eventId) {
  return getParticipantsByGreetingStatus(ref, eventId, GreetingStatus.noneNearby);
});

final noneGreetingParticipantUserIdOnEventProvider = StreamProvider.family<List<Participant>, String>((ref, eventId) {
  return getParticipantsByGreetingStatus(ref, eventId, GreetingStatus.none);
});
