import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/greeting.dart';

class GreetingConverter {
  static Greeting fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Greeting(
      id: snapshot.id,
      numTokens: data['num_tokens'] ?? 0,
      createTime: (data['create_time'] as Timestamp).toDate(),
      postUserId: (data['post_user'] as DocumentReference).id,
      targetUserId: (data['target_user'] as DocumentReference).id,
      eventId: (data['event'] as DocumentReference).id,
      isHidden: data['is_hidden'] ?? false,
    );
  }

  static Map<String, dynamic> toFirestore(Greeting greeting) {
    return {
      'num_tokens': greeting.numTokens,
      'create_time': greeting.createTime,
      'post_user': FirebaseFirestore.instance.collection('users').doc(greeting.postUserId),
      'target_user': FirebaseFirestore.instance.collection('users').doc(greeting.targetUserId),
      'event': FirebaseFirestore.instance.collection('events').doc(greeting.eventId),
      'is_hidden': greeting.isHidden,
    };
  }
}
