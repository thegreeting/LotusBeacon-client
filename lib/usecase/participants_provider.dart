import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/driver/firebase/firestore_provider.dart';
import 'package:lotusbeacon/usecase/auth_provider.dart';

final participantUserIdsOnEventProvider = StreamProvider.family<List<String>, String>((
  ref,
  eventId,
) {
  // TODO(knaoe): To be impl.
  return const Stream.empty();
});

// Soft participation means that the user has participated in the event, but confirmed by web2 not web3.
// We prefer web2 storage for user's participation status to improve the user experience.
// Using web3 in this case is too much.
final hasSoftParticipatedOnEventProvider = Provider.family<bool, String>((
  ref,
  eventId,
) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return false;
  }
  // TODO(knaoe): To be impl. fetch from remote web2 storage.
  return false;
});

Future<bool> hasSoftRegisteredOnEvent({
  required String eventId,
  required String userId,
}) async {
  final firestore = FirebaseFirestore.instance;
  final docSnapshot = await firestore.collection('events').doc(eventId).collection('participants').doc(userId).get();
  return docSnapshot.exists;
}

Future<void> participateUserOnEventOrHardRegisterIfNeeded(
  WidgetRef ref, {
  required String eventId,
  required String userId,
}) async {
  // TODO(knaoe): call to Contract to get eventUserIndex

  // TODO(knaoe): call to Contract to register user on event to issue eventUserIndex if not registered

  final firestore = await ref.read(firestoreProvider.future);
  final batch = firestore.batch();
  // TODO(knaoe): update web2 storage. profile

  // TODO(knaoe): update web2 storage. event.participants
  batch.set(firestore.collection('events').doc(eventId).collection('participants').doc(userId), {
    'create_time': FieldValue.serverTimestamp(),
  });
  await batch.commit();
}
