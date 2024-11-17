import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/firebase_options.dart';

final firestoreProvider = FutureProvider<FirebaseFirestore>(
  (ref) async {
    final FirebaseApp app = await Firebase.initializeApp(
      name: 'lotusbeacon',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
    return firestore;
  },
);
