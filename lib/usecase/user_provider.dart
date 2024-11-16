import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/application/fixture/user_fixture.dart';
import 'package:lotusbeacon/domain/auth_state.dart';
import 'package:lotusbeacon/domain/user.dart';
import 'package:lotusbeacon/usecase/auth_provider.dart';

final currentUserProvider = StreamProvider<User?>((ref) {
  final authState = ref.watch(authStateProvider);

  if (authState.asData?.value == null) {
    return const Stream.empty();
  }

  if (authState.asData!.value.status == AppAuthStatus.unauthenticated) {
    return const Stream.empty();
  }

  final userId = authState.asData!.value.userId!;

  // TODO(knaoe): watch remote profile
  return Stream.value(UserFixture.dummy(userId));
});

final currenEventUserIndexProvider = StateProvider<int?>((ref) {
  return null;
});

final userProvider = StreamProvider.family<
    User?,
    ({
      String eventId,
      String userId,
    })>((ref, params) {
  // final eventId = params.eventId;
  // final userId = params.userId;
  // TODO(knaoe): To be impl. fetch from remote web2 storage.
  return const Stream.empty();
});

Future<void> putUser({
  required String eventId,
  required String userId,
  required UpdateUserParams params,
}) async {
  // TODO(knaoe): To be impl. put to remote web2 storage.
  return;
}
