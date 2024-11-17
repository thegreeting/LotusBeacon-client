import 'package:lotusbeacon/domain/event.dart';
import 'package:uuid/uuid.dart';

class EventFixture {
  static final ethbangkok2024 = Event(
    // ee25a043-8486-5a6a-9dc0-db8f4fe2ea3f
    id: const Uuid().v5(Namespace.url.value, 'eth.web3beacon.ethbangkok2024.0').toUpperCase(),
    name: 'ETHGlobal Bangkok',
    description: '2024/11/15-17 @QSNCS',
    iconEmoji: '🇹🇭',
    startTime: DateTime(2024, 11, 15),
    endTime: DateTime(2024, 11, 17),
  );
}
