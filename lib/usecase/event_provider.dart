import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/application/fixture/event_fixture.dart';
import 'package:lotusbeacon/domain/event.dart';

final selectedEventProvider = StateProvider<Event>((ref) {
  final overrideEventId = ref.watch(overrideEeventIdProvider);
  if (overrideEventId != null) {
    return EventFixture.ethbangkok2024.copyWith(
      id: overrideEventId,
    );
  }
  return EventFixture.ethbangkok2024;
});

final overrideEeventIdProvider = StateProvider<String?>((ref) {
  return null;
});
