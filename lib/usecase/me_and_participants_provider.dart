import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/application/config/logger.dart';
import 'package:lotusbeacon/application/fixture/user_fixture.dart';
import 'package:lotusbeacon/domain/greeting.dart';
import 'package:lotusbeacon/domain/participant.dart';
import 'package:lotusbeacon/domain/physical_proximity.dart';
import 'package:lotusbeacon/usecase/auth_provider.dart';
import 'package:lotusbeacon/usecase/bluetooth_provider.dart';
import 'package:lotusbeacon/usecase/participants_provider.dart';

GreetingStatus _getMockGreetingStatus(EstimatedDistance distance) {
  switch (distance) {
    case EstimatedDistance.immediate:
      return GreetingStatus.mutual;
    case EstimatedDistance.near:
      return GreetingStatus.sent;
    case EstimatedDistance.far:
      return GreetingStatus.received;
    default:
      return GreetingStatus.none;
  }
}

final meAndParticipantOnEventProvider = StreamProvider.family<
    Participant?,
    ({
      String eventId,
      String participantUserId,
    })>((ref, params) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return Stream.value(null);
  }

  final proximities = ref.watch(proximityStreamProvider).asData?.value ?? [];
  final detectedParticipant = proximities
      .where((p) => p.eventId == params.eventId && p.userIndex.toString() == params.participantUserId)
      .firstOrNull;

  if (detectedParticipant != null) {
    final mockUser = UserFixture.findUserByEventUserIndex(int.parse(detectedParticipant.userIndex));
    logger.info('detectedParticipant: $detectedParticipant, mockUser: $mockUser');

    return Stream.value(Participant(
      user: mockUser,
      greetingStatus: GreetingStatus.none, //_getMockGreetingStatus(detectedParticipant.distance),
    ));
  }
  return Stream.value(null);
});

List<Participant> getParticipantsByGreetingStatusStream(Ref ref, String eventId, GreetingStatus status) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    return [];
  }

  final participantUserIds = ref.watch(participantUserIdsOnEventProvider(eventId)).asData?.value ?? [];

  final participants = <Participant>[];

  for (final participantUserId in participantUserIds) {
    final participant = ref
        .watch(meAndParticipantOnEventProvider(
          (eventId: eventId, participantUserId: participantUserId),
        ))
        .asData
        ?.value;

    if (participant != null && participant.greetingStatus == status) {
      participants.add(participant);
    }
  }

  return participants;
}

final mutualGreetingParticipantsOnEventProvider = StreamProvider.family<List<Participant>, String>((ref, eventId) {
  return Stream.value(getParticipantsByGreetingStatusStream(ref, eventId, GreetingStatus.mutual));
});

final sentGreetingParticipantsOnEventProvider = StreamProvider.family<List<Participant>, String>((ref, eventId) {
  return Stream.value(getParticipantsByGreetingStatusStream(ref, eventId, GreetingStatus.sent));
});

final receivedGreetingParticipantsOnEventProvider = StreamProvider.family<List<Participant>, String>((ref, eventId) {
  return Stream.value(getParticipantsByGreetingStatusStream(ref, eventId, GreetingStatus.received));
});

final noneGreetingButNearByParticipantsOnEventProvider =
    StreamProvider.family<List<Participant>, String>((ref, eventId) {
  final noneGreetingParticipants = getParticipantsByGreetingStatusStream(ref, eventId, GreetingStatus.none);
  // TODO(knaoe): retrieve from BLE
  final nearByUserId = [
    UserFixture.ipadmini().userId,
    UserFixture.iphone16pro().userId,
  ];
  // filter by nearByUserId
  return Stream.value(noneGreetingParticipants.where((e) => nearByUserId.contains(e.user.userId)).toList());
});

final noneGreetingParticipantsOnEventProvider = StreamProvider.family<List<Participant>, String>((ref, eventId) {
  final noneGreetingParticipants = getParticipantsByGreetingStatusStream(ref, eventId, GreetingStatus.none);
  // TODO(knaoe): retrieve from BLE
  final nearByUserId = [];
  // filter by nearByUserId
  return Stream.value(noneGreetingParticipants.where((e) => !nearByUserId.contains(e.user.userId)).toList());
});
