import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/application/fixture/user_fixture.dart';
import 'package:lotusbeacon/domain/user.dart';

final currentUserProvider = StreamProvider<User?>((ref) {
  // final authState = ref.watch(authStateProvider);

  // if (authState.asData?.value == null) {
  //   return const Stream.empty();
  // }

  // if (authState.asData!.value.status == AppAuthStatus.unauthenticated) {
  //   return const Stream.empty();
  // }

  // final userId = authState.asData!.value.userId!;

  // // TODO(knaoe): watch remote profile
  // return Stream.value(UserFixture.dummy(userId));
  final random = Random();
  final isIpad = random.nextBool();

  if (isIpad) {
    return Stream.value(UserFixture.ipadmini());
  } else {
    return Stream.value(UserFixture.iphone16pro());
  }
});

final currenEventUserIndexProvider = Provider<int?>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  return user?.eventUserIndex;
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
