import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreBackup {
  final _db = FirebaseFirestore.instance;

  Future<String> exportJson() async {
    final collections = ['clients', 'products', 'orders', 'expenses'];
    final Map<String, dynamic> out = {'version': 1};
    for (final c in collections) {
      final snap = await _db.collection(c).get();
      out[c] = snap.docs
          .map((d) => {
                'id': d.id,
                ...d.data(),
              })
          .toList();
    }
    return jsonEncode(out);
  }

  Future<void> importJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final batch = _db.batch();
    Future<void> _replace(String col, List list) async {
      final ref = _db.collection(col);
      final snap = await ref.get();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      for (final item in list) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = map.remove('id')?.toString();
        if (id == null) continue;
        batch.set(ref.doc(id), map);
      }
    }

    await _replace('clients', (data['clients'] as List?) ?? []);
    await _replace('products', (data['products'] as List?) ?? []);
    await _replace('orders', (data['orders'] as List?) ?? []);
    await _replace('expenses', (data['expenses'] as List?) ?? []);
    await batch.commit();
  }
}
