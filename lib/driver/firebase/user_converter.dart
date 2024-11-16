import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/user.dart';

class UserConverter {
  static User fromFirestore(Map<String, dynamic> json) {
    final createTime = (json['create_time'] as Timestamp? ?? json['created_time'] as Timestamp).toDate();
    return User(
      userId: json['userId'] as String,
      displayName: json['display_name'] as String? ?? '❓',
      bio: json['bio'] as String? ?? '',
      createTime: createTime,
      updateTime: json.keys.contains('update_time') ? (json['update_time'] as Timestamp).toDate() : createTime,
    );
  }

  static Map<String, dynamic> toFirestore(User user) {
    return {
      'userId': user.userId,
      'display_name': user.displayName,
      'bio': user.bio,
      'create_time': Timestamp.fromDate(user.createTime),
      'update_time': Timestamp.fromDate(user.updateTime),
    };
  }
}
