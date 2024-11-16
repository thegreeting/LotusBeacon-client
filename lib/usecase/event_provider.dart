import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/application/fixture/event_fixture.dart';
import 'package:lotusbeacon/domain/event.dart';

final selectedEventProvider = StateProvider<Event?>((ref) {
  return EventFixture.ethbangkok2024;
});
