import 'package:delicias_da_may/data/local_db.dart';
import 'package:delicias_da_may/models/expense.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseRepository {
  final dbFuture = LocalDb.instance.database;

  Future<int> insert(Expense expense) async {
    final db = await dbFuture;
    return db.insert(Expense.table, expense.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Expense>> getByDate(DateTime date) async {
    final db = await dbFuture;
    final start = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final maps = await db.query(
      Expense.table,
      where: 'time BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'time DESC',
    );
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<double> sumByMonth(int year, int month) async {
    final db = await dbFuture;
    final start = DateTime(year, month, 1).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999).millisecondsSinceEpoch;
    final res = await db.rawQuery(
      'SELECT SUM(valor) as total FROM ${Expense.table} WHERE time BETWEEN ? AND ?',
      [start, end],
    );
    final v = (res.first['total'] as num?)?.toDouble() ?? 0.0;
    return v;
  }

  Future<Expense?> getById(int id) async {
    final db = await dbFuture;
    final res = await db.query(Expense.table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    return Expense.fromMap(res.first);
  }

  Future<int> delete(int id) async {
    final db = await dbFuture;
    return db.delete(Expense.table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Expense expense) async {
    final db = await dbFuture;
    return db.update(Expense.table, expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<double> sumByYear(int year) async {
    final db = await dbFuture;
    final start = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final end = DateTime(year, 12, 31, 23, 59, 59, 999).millisecondsSinceEpoch;
    final res = await db.rawQuery(
      'SELECT SUM(valor) as total FROM ${Expense.table} WHERE time BETWEEN ? AND ?',
      [start, end],
    );
    final v = (res.first['total'] as num?)?.toDouble() ?? 0.0;
    return v;
  }
}
