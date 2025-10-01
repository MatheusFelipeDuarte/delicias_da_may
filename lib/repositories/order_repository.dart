import 'package:delicias_da_may/models/order.dart';
import 'package:delicias_da_may/core/enums.dart';
import 'package:delicias_da_may/data/firestore_db.dart';
import 'package:delicias_da_may/data/firestore_counters.dart';

class OrderRepository {
  final _col = FirestoreDb.ordersCol();

  Future<int> insert(Order order) async {
    final id = order.id ?? await FirestoreCounters.next('orders');
    await _col.doc(id.toString()).set({
      'produto_id': order.produtoId,
      'cliente_id': order.clienteId,
      'valor': order.valor,
      'quantidade': order.quantidade,
      'pagamento': order.pagamento.label,
      'time': order.time.millisecondsSinceEpoch,
    });
    return 1;
  }

  Future<List<Order>> listAll() async {
    final snap = await _col.orderBy('time', descending: true).get();
    return snap.docs.map((d) {
      final m = d.data();
      return Order.fromMap({
        'id': int.tryParse(d.id),
        'produto_id': m['produto_id'],
        'cliente_id': m['cliente_id'],
        'valor': m['valor'],
        'quantidade': m['quantidade'] ?? 1,
        'pagamento': m['pagamento'],
        'time': m['time'],
      });
    }).toList();
  }

  Future<List<Order>> getByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final snap = await _col
        .where('time', isGreaterThanOrEqualTo: start)
        .where('time', isLessThanOrEqualTo: end)
        .orderBy('time', descending: true)
        .get();
    return snap.docs.map((d) {
      final m = d.data();
      // Ensure map has expected keys for Order.fromMap
      return Order.fromMap({
        'id': int.tryParse(d.id),
        'produto_id': m['produto_id'],
        'cliente_id': m['cliente_id'],
        'valor': m['valor'],
        'quantidade': m['quantidade'] ?? 1,
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

  Future<Order?> getById(int id) async {
    final doc = await _col.doc(id.toString()).get();
    if (!doc.exists) return null;
    return Order.fromMap({'id': id, ...doc.data()!});
  }

  Future<int> delete(int id) async {
    await _col.doc(id.toString()).delete();
    return 1;
  }

  Future<int> update(Order order) async {
    final id = order.id;
    if (id == null) return 0;
    await _col.doc(id.toString()).update({
      'produto_id': order.produtoId,
      'cliente_id': order.clienteId,
      'valor': order.valor,
      'quantidade': order.quantidade,
      'pagamento': order.pagamento.label,
      'time': order.time.millisecondsSinceEpoch,
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

  Future<int> countByMonth(int year, int month) async {
    final start = DateTime(year, month, 1).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999).millisecondsSinceEpoch;
    final snap = await _col
        .where('time', isGreaterThanOrEqualTo: start)
        .where('time', isLessThanOrEqualTo: end)
        .get();
    return snap.docs.length;
  }

  Future<int> countByYear(int year) async {
    final start = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final end = DateTime(year, 12, 31, 23, 59, 59, 999).millisecondsSinceEpoch;
    final snap = await _col
        .where('time', isGreaterThanOrEqualTo: start)
        .where('time', isLessThanOrEqualTo: end)
        .get();
    return snap.docs.length;
  }

  Future<List<Order>> listByRange(DateTime startDt, DateTime endDt) async {
    final start = DateTime(startDt.year, startDt.month, startDt.day).millisecondsSinceEpoch;
    final end = DateTime(endDt.year, endDt.month, endDt.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final snap = await _col
        .where('time', isGreaterThanOrEqualTo: start)
        .where('time', isLessThanOrEqualTo: end)
        .get();
    return snap.docs.map((d) {
      final m = d.data();
      return Order.fromMap({
        'id': int.tryParse(d.id),
        'produto_id': m['produto_id'],
        'cliente_id': m['cliente_id'],
        'valor': m['valor'],
        'quantidade': m['quantidade'] ?? 1,
        'pagamento': m['pagamento'],
        'time': m['time'],
      });
    }).toList();
  }
}
