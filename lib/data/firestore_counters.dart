import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCounters {
  static final _db = FirebaseFirestore.instance;
  static final _doc = _db.collection('meta').doc('counters');

  static Future<int> next(String key) async {
    return _db.runTransaction<int>((tx) async {
      final snap = await tx.get(_doc);
  final data = snap.data() ?? <String, dynamic>{};
      final current = (data[key] as num?)?.toInt() ?? 0;
      final next = current + 1;
      tx.set(_doc, {...data, key: next}, SetOptions(merge: true));
      return next;
    });
  }
}
