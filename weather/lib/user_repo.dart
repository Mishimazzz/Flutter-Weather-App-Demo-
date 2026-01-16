import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepo {
  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> saveLastCity({
    required String name,
    required String country,
    required double lat,
    required double lon,
  }) {
    return _db.collection('users').doc(uid).set({
      'lastCity': {
        'name': name,
        'country': country,
        'lat': lat,
        'lon': lon,
        'updatedAt': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> loadLastCity() async {
    final snap = await _db.collection('users').doc(uid).get();
    final data = snap.data();
    return (data?['lastCity'] as Map?)?.cast<String, dynamic>();
  }
}
