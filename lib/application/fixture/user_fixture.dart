import 'package:lotusbeacon/domain/user.dart';

class UserFixture {
  static User dummy(String userId) {
    return User(
      userId: userId,
      displayName: userId.substring(0, 2),
      bio: 'Hello!',
      createTime: DateTime.now(),
      updateTime: DateTime.now(),
    );
  }
}
