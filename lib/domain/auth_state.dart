enum AppAuthStatus {
  authenticated,
  unauthenticated,
  anonymous,
}

class AppAuthState {
  final AppAuthStatus status;
  final String? userId;

  AppAuthState({
    required this.status,
    this.userId,
  });

  factory AppAuthState.unauthenticated() {
    return AppAuthState(status: AppAuthStatus.unauthenticated);
  }

  factory AppAuthState.anonymous(String userId) {
    return AppAuthState(status: AppAuthStatus.anonymous, userId: userId);
  }

  factory AppAuthState.authenticated(String userId) {
    return AppAuthState(
      status: AppAuthStatus.authenticated,
      userId: userId,
    );
  }
}
