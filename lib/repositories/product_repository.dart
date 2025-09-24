import 'package:delicias_da_may/data/local_db.dart';
import 'package:delicias_da_may/models/product.dart';

class ProductRepository {
  final dbFuture = LocalDb.instance.database;

  Future<Product?> getById(int id) async {
    final db = await dbFuture;
    final res = await db.query(Product.table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    return Product.fromMap(res.first);
  }

  Future<List<Product>> listAll() async {
    final db = await dbFuture;
    final res = await db.query(Product.table, orderBy: 'nome ASC');
    return res.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> insert(Product product) async {
    final db = await dbFuture;
    return db.insert(Product.table, product.toMap());
  }

  Future<int> delete(int id) async {
    final db = await dbFuture;
    return db.delete(Product.table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Product product) async {
    final db = await dbFuture;
    return db.update(Product.table, product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }
}
