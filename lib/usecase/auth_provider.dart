import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/config/logger.dart';
import '../domain/auth_state.dart';

final authStateProvider = FutureProvider<AppAuthState>((ref) async {
  // return web3Auth.authStateChanges().map((e) {
  //   if (e == null) {
  //     return AppAuthState.unauthenticated();
  //   } else {
  //     return AppAuthState.authenticated(e.address);
  //   }
  // });
  return AppAuthState.authenticated('0xken');
});

final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider); // Ensure refresh when auth state changes
  logger.info('currentUserId: ${authState.asData?.value.userId}');
  return authState.asData?.value.userId;
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AppAuthState>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<AppAuthState>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _ref.listen(authStateProvider, (_, next) {
      state = next;
    });
  }

  Future<void> signIn() async {
    final currentState = await _ref.read(authStateProvider.future);
    if (currentState.status == AppAuthStatus.unauthenticated) {
      // try {
      //   await web3Auth.connect();
      // } catch (e) {
      //   state = AsyncValue.error(e, StackTrace.current);
      // }
    }
  }

  Future<void> signOut() async {
    // try {
    //   await web3Auth.disconnect();
    // } catch (e) {
    //   state = AsyncValue.error(e, StackTrace.current);
    // }
  }
}
