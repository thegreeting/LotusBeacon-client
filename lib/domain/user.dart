class User {
  const User({
    required this.userId,
    required this.displayName,
    this.bio = '',
    this.avatarUrl,
    required this.createTime,
    required this.updateTime,
  });

  final String userId;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final DateTime createTime;
  final DateTime updateTime;
}

class UpdateUserParams {
  const UpdateUserParams({
    this.displayName,
    this.bio,
    this.avatarUrl,
  });

  final String? displayName;
  final String? bio;
  final String? avatarUrl;
}
