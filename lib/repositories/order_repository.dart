import 'package:delicias_da_may/data/local_db.dart';
import 'package:delicias_da_may/models/order.dart';
import 'package:sqflite/sqflite.dart';

class OrderRepository {
  final dbFuture = LocalDb.instance.database;

  Future<int> insert(Order order) async {
    final db = await dbFuture;
    return db.insert(Order.table, order.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Order>> getByDate(DateTime date) async {
    final db = await dbFuture;
    final start = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final maps = await db.query(
      Order.table,
      where: 'time BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'time DESC',
    );
    return maps.map((e) => Order.fromMap(e)).toList();
  }

  Future<double> sumByMonth(int year, int month) async {
    final db = await dbFuture;
    final start = DateTime(year, month, 1).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999).millisecondsSinceEpoch;
    final res = await db.rawQuery(
      'SELECT SUM(valor) as total FROM ${Order.table} WHERE time BETWEEN ? AND ?',
      [start, end],
    );
    final v = (res.first['total'] as num?)?.toDouble() ?? 0.0;
    return v;
  }

  Future<Order?> getById(int id) async {
    final db = await dbFuture;
    final res = await db.query(Order.table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    return Order.fromMap(res.first);
  }

  Future<int> delete(int id) async {
    final db = await dbFuture;
    return db.delete(Order.table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Order order) async {
    final db = await dbFuture;
    return db.update(Order.table, order.toMap(), where: 'id = ?', whereArgs: [order.id]);
  }

  Future<double> sumByYear(int year) async {
    final db = await dbFuture;
    final start = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final end = DateTime(year, 12, 31, 23, 59, 59, 999).millisecondsSinceEpoch;
    final res = await db.rawQuery(
      'SELECT SUM(valor) as total FROM ${Order.table} WHERE time BETWEEN ? AND ?',
      [start, end],
    );
    final v = (res.first['total'] as num?)?.toDouble() ?? 0.0;
    return v;
  }

  Future<int> countByMonth(int year, int month) async {
    final db = await dbFuture;
    final start = DateTime(year, month, 1).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999).millisecondsSinceEpoch;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${Order.table} WHERE time BETWEEN ? AND ?',
      [start, end],
    );
    return (res.first['cnt'] as num?)?.toInt() ?? 0;
  }

  Future<int> countByYear(int year) async {
    final db = await dbFuture;
    final start = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final end = DateTime(year, 12, 31, 23, 59, 59, 999).millisecondsSinceEpoch;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${Order.table} WHERE time BETWEEN ? AND ?',
      [start, end],
    );
    return (res.first['cnt'] as num?)?.toInt() ?? 0;
  }
}
