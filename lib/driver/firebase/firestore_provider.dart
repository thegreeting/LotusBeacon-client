import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) {
    final app = Firebase.app('lotusbeacon'); // Firestore db name
    FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
    return firestore;
  },
);
