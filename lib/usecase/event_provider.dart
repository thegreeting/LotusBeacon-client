import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/application/fixture/event_fixture.dart';
import 'package:lotusbeacon/domain/event.dart';
import 'package:uuid/uuid.dart';

final selectedEventProvider = StateProvider<Event>((ref) {
  final overrideEventIdIndex = ref.watch(overrideEeventIdIndexProvider);
  if (overrideEventIdIndex != null) {
    return EventFixture.ethbangkok2024.copyWith(
      id: const Uuid().v5(Namespace.url.value, 'eth.web3beacon.ethbangkok2024.$overrideEventIdIndex'),
    );
  }
  return EventFixture.ethbangkok2024;
});

final overrideEeventIdIndexProvider = StateProvider<String?>((ref) {
  return null;
});
