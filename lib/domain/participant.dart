import 'greeting.dart';
import 'user.dart';

class Participant {
  Participant({
    required this.user,
    required this.greetingStatus,
  });

  final User user;
  final GreetingStatus greetingStatus;
}
