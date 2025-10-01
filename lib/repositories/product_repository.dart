import 'package:delicias_da_may/models/product.dart';
import 'package:delicias_da_may/data/firestore_db.dart';
import 'package:delicias_da_may/data/firestore_counters.dart';

class ProductRepository {
  final _col = FirestoreDb.productsCol();

  Future<Product?> getById(int id) async {
    final doc = await _col.doc(id.toString()).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return Product.fromMap({'id': id, 'nome': data['nome']});
  }

  Future<List<Product>> listAll() async {
    final snap = await _col.orderBy('nome').get();
    return snap.docs
        .map((d) => Product.fromMap({'id': int.tryParse(d.id), 'nome': d.data()['nome']}))
        .toList();
  }

  Future<List<Product>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    // Firestore whereIn on documentId is limited and may not be available across large sets
    // For simplicity and small expected sizes, fetch individually in parallel
    final futures = ids.map((id) async {
      final d = await _col.doc(id.toString()).get();
      if (!d.exists) return null;
      return Product.fromMap({'id': id, 'nome': d.data()!['nome']});
    });
    final results = await Future.wait(futures);
    return results.whereType<Product>().toList();
  }

  Future<int> insert(Product product) async {
    final id = product.id ?? await FirestoreCounters.next('products');
    await _col.doc(id.toString()).set({'nome': product.nome});
    return 1;
  }

  Future<int> delete(int id) async {
    await _col.doc(id.toString()).delete();
    return 1;
  }

  Future<int> update(Product product) async {
    final id = product.id;
    if (id == null) return 0;
    await _col.doc(id.toString()).update({'nome': product.nome});
    return 1;
  }
}
