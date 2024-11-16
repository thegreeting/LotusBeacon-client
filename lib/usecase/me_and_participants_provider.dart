import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/domain/greeting.dart';
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

final mutualGreetingParticipantOnEventProvider = StreamProvider.family<List<Participant>, String>((ref, eventId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return const Stream.empty();
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
    if (participant.greetingStatus == GreetingStatus.mutual) {
      participants.add(participant);
    }
  }

  return Stream.value(participants);
});

final sentGreetingParticipantUserIdOnEventProvider = StreamProvider.family<List<Participant>, String>((ref, eventId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return const Stream.empty();
  }
  final participantUserIds = ref.watch(participantUserIdsOnEventProvider(eventId));
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});

final receivedGreetingParticipantUserIdOnEventProvider =
    StreamProvider.family<List<Participant>, String>((ref, eventId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return const Stream.empty();
  }
  final participantUserIds = ref.watch(participantUserIdsOnEventProvider(eventId));
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});

final noneGreetingButNearByParticipantUserIdOnEventProvider =
    StreamProvider.family<List<Participant>, String>((ref, eventId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return const Stream.empty();
  }
  final participantUserIds = ref.watch(participantUserIdsOnEventProvider(eventId));
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});

final noneGreetingParticipantUserIdOnEventProvider = StreamProvider.family<List<Participant>, String>((ref, eventId) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return const Stream.empty();
  }
  final participantUserIds = ref.watch(participantUserIdsOnEventProvider(eventId));
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});
