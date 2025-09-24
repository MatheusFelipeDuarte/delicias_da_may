import 'package:delicias_da_may/data/local_db.dart';
import 'package:delicias_da_may/models/client.dart';

class ClientRepository {
  final dbFuture = LocalDb.instance.database;

  Future<Client?> getById(int id) async {
    final db = await dbFuture;
    final res = await db.query(Client.table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    return Client.fromMap(res.first);
  }

  Future<List<Client>> listAll() async {
    final db = await dbFuture;
    final res = await db.query(Client.table, orderBy: 'nome ASC');
    return res.map((e) => Client.fromMap(e)).toList();
  }

  Future<int> insert(Client client) async {
    final db = await dbFuture;
    return db.insert(Client.table, client.toMap());
  }

  Future<int> delete(int id) async {
    final db = await dbFuture;
    return db.delete(Client.table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Client client) async {
    final db = await dbFuture;
    return db.update(Client.table, client.toMap(), where: 'id = ?', whereArgs: [client.id]);
  }
}
