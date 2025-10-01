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
