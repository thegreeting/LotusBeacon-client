import 'package:lotusbeacon/domain/user.dart';

class UserFixture {
  static User dummy(String userId) {
    return User(
      userId: userId,
      displayName: userId.substring(0, 2),
      bio: 'Hello!',
      createTime: DateTime.now(),
      updateTime: DateTime.now(),
      eventUserIndex: 0,
    );
  }

  static User ipadmini() {
    return User(
      userId: '0xipadmini',
      displayName: 'Kate',
      bio: 'Hello!',
      createTime: DateTime.now(),
      updateTime: DateTime.now(),
      eventUserIndex: 10,
    );
  }

  static User iphone16pro() {
    return User(
      userId: '0xiphone',
      displayName: 'Ken',
      bio: 'Hello!',
      createTime: DateTime.now(),
      updateTime: DateTime.now(),
      eventUserIndex: 20,
    );
  }
}
