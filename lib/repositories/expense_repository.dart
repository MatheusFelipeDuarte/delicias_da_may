import 'package:delicias_da_may/models/expense.dart';
import 'package:delicias_da_may/core/enums.dart';
import 'package:delicias_da_may/data/firestore_db.dart';
import 'package:delicias_da_may/data/firestore_counters.dart';

class ExpenseRepository {
  final _col = FirestoreDb.expensesCol();

  Future<int> insert(Expense expense) async {
    final id = expense.id ?? await FirestoreCounters.next('expenses');
    await _col.doc(id.toString()).set({
      'categoria': expense.categoria.label,
      'valor': expense.valor,
      'pagamento': expense.pagamento.label,
      'time': expense.time.millisecondsSinceEpoch,
    });
    return 1;
  }

  Future<List<Expense>> getByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final snap = await _col
        .where('time', isGreaterThanOrEqualTo: start)
        .where('time', isLessThanOrEqualTo: end)
        .orderBy('time', descending: true)
        .get();
    return snap.docs.map((d) {
      final m = d.data();
      return Expense.fromMap({
        'id': int.tryParse(d.id),
        'categoria': m['categoria'],
        'valor': m['valor'],
        'pagamento': m['pagamento'],
        'time': m['time'],
      });
    }).toList();
  }

  Future<double> sumByMonth(int year, int month) async {
    final start = DateTime(year, month, 1).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999).millisecondsSinceEpoch;
    final snap = await _col
        .where('time', isGreaterThanOrEqualTo: start)
        .where('time', isLessThanOrEqualTo: end)
        .get();
    return snap.docs.fold<double>(0.0, (p, d) => p + ((d.data()['valor'] as num?)?.toDouble() ?? 0.0));
  }

  Future<Expense?> getById(int id) async {
    final doc = await _col.doc(id.toString()).get();
    if (!doc.exists) return null;
    return Expense.fromMap({'id': id, ...doc.data()!});
  }

  Future<int> delete(int id) async {
    await _col.doc(id.toString()).delete();
    return 1;
  }

  Future<int> update(Expense expense) async {
    final id = expense.id;
    if (id == null) return 0;
    await _col.doc(id.toString()).update({
      'categoria': expense.categoria.label,
      'valor': expense.valor,
      'pagamento': expense.pagamento.label,
      'time': expense.time.millisecondsSinceEpoch,
    });
    return 1;
  }

  Future<double> sumByYear(int year) async {
    final start = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final end = DateTime(year, 12, 31, 23, 59, 59, 999).millisecondsSinceEpoch;
    final snap = await _col
        .where('time', isGreaterThanOrEqualTo: start)
        .where('time', isLessThanOrEqualTo: end)
        .get();
    return snap.docs.fold<double>(0.0, (p, d) => p + ((d.data()['valor'] as num?)?.toDouble() ?? 0.0));
  }
}
