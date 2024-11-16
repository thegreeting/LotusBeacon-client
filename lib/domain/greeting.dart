enum GreetingStatus {
  sameUser,
  mutual,
  sent,
  received,
  none,
}

class Greeting {
  final String id;
  final int numTokens;
  final DateTime createTime;
  final String postUserId;
  final String targetUserId;
  final String eventId;
  final bool isHidden;

  Greeting({
    required this.id,
    required this.numTokens,
    required this.createTime,
    required this.postUserId,
    required this.targetUserId,
    required this.eventId,
    this.isHidden = false,
  });

  String get message {
    switch (numTokens) {
      case 3:
        return 'Looking forward to working with you!';
      case 2:
        return 'We have a common topic!';
      case 1:
      default:
        return 'Nice to meet you!';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'num_tokens': numTokens,
      'create_time': createTime,
      'post_user': postUserId,
      'target_user': targetUserId,
      'event_id': eventId,
      'is_hidden': isHidden,
    };
  }

  Greeting copyWith({
    String? id,
    int? numTokens,
    DateTime? createTime,
    String? postUserId,
    String? targetUserId,
    String? eventId,
    bool? isHidden,
  }) {
    return Greeting(
      id: id ?? this.id,
      numTokens: numTokens ?? this.numTokens,
      createTime: createTime ?? this.createTime,
      postUserId: postUserId ?? this.postUserId,
      targetUserId: targetUserId ?? this.targetUserId,
      eventId: eventId ?? this.eventId,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
