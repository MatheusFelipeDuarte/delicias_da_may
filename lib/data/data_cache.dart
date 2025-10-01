import 'package:delicias_da_may/models/client.dart';
import 'package:delicias_da_may/models/product.dart';
import 'package:delicias_da_may/models/order.dart';
import 'package:delicias_da_may/models/expense.dart';
import 'package:delicias_da_may/repositories/client_repository.dart';
import 'package:delicias_da_may/repositories/product_repository.dart';
import 'package:delicias_da_may/repositories/order_repository.dart';
import 'package:delicias_da_may/repositories/expense_repository.dart';

class DataCache {
  DataCache._();
  static final DataCache instance = DataCache._();

  bool _loaded = false;
  DateTime? _lastLoadedAt;

  final Map<int, Client> _clients = {};
  final Map<int, Product> _products = {};
  final List<Order> _orders = [];
  final List<Expense> _expenses = [];

  bool get isLoaded => _loaded;
  DateTime? get lastLoadedAt => _lastLoadedAt;

  List<Client> get clients => _clients.values.toList()..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  List<Product> get products => _products.values.toList()..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  List<Order> get orders => List.unmodifiable(_orders);
  List<Expense> get expenses => List.unmodifiable(_expenses);

  Future<void> ensureLoaded({
    required ClientRepository clientsRepo,
    required ProductRepository productsRepo,
    required OrderRepository ordersRepo,
    required ExpenseRepository expensesRepo,
  }) async {
    if (_loaded) return;
    await refreshAll(
      clientsRepo: clientsRepo,
      productsRepo: productsRepo,
      ordersRepo: ordersRepo,
      expensesRepo: expensesRepo,
    );
  }

  Future<void> refreshAll({
    required ClientRepository clientsRepo,
    required ProductRepository productsRepo,
    required OrderRepository ordersRepo,
    required ExpenseRepository expensesRepo,
  }) async {
    final cs = await clientsRepo.listAll();
    final ps = await productsRepo.listAll();
    final os = await ordersRepo.listAll();
    final es = await expensesRepo.listAll();
    _clients
      ..clear()
      ..addEntries(cs.where((c) => c.id != null).map((c) => MapEntry(c.id!, c)));
    _products
      ..clear()
      ..addEntries(ps.where((p) => p.id != null).map((p) => MapEntry(p.id!, p)));
    _orders
      ..clear()
      ..addAll(os);
    _expenses
      ..clear()
      ..addAll(es);
    _loaded = true;
    _lastLoadedAt = DateTime.now();
  }

  // Incremental updates
  void addOrder(Order o) {
    _orders.add(o);
  }
  void updateOrder(Order o) {
    final i = _orders.indexWhere((e) => e.id == o.id);
    if (i >= 0) _orders[i] = o;
  }
  void deleteOrder(int id) {
    _orders.removeWhere((e) => e.id == id);
  }

  void addExpense(Expense e) {
    _expenses.add(e);
  }
  void updateExpense(Expense e) {
    final i = _expenses.indexWhere((x) => x.id == e.id);
    if (i >= 0) _expenses[i] = e;
  }
  void deleteExpense(int id) {
    _expenses.removeWhere((x) => x.id == id);
  }

  void addClient(Client c) { if (c.id != null) _clients[c.id!] = c; }
  void updateClient(Client c) { if (c.id != null) _clients[c.id!] = c; }
  void deleteClient(int id) { _clients.remove(id); }

  void addProduct(Product p) { if (p.id != null) _products[p.id!] = p; }
  void updateProduct(Product p) { if (p.id != null) _products[p.id!] = p; }
  void deleteProduct(int id) { _products.remove(id); }

  // Query helpers from cache
  List<Order> ordersByDate(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
    return ordersByRange(start, end);
  }

  List<Order> ordersByRange(DateTime start, DateTime end) {
    return _orders.where((o) => !o.time.isBefore(start) && !o.time.isAfter(end)).toList()
      ..sort((a, b) => b.time.compareTo(a.time));
  }

  List<Expense> expensesByDate(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
    return expensesByRange(start, end);
  }

  List<Expense> expensesByRange(DateTime start, DateTime end) {
    return _expenses.where((e) => !e.time.isBefore(start) && !e.time.isAfter(end)).toList()
      ..sort((a, b) => b.time.compareTo(a.time));
  }

  double sumOrdersByMonth(int year, int month) {
    final s = DateTime(year, month, 1);
    final e = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    return ordersByRange(s, e).fold<double>(0, (p, o) => p + o.valor);
  }

  double sumExpensesByMonth(int year, int month) {
    final s = DateTime(year, month, 1);
    final e = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    return expensesByRange(s, e).fold<double>(0, (p, x) => p + x.valor);
  }

  int countOrdersByMonth(int year, int month) {
    final s = DateTime(year, month, 1);
    final e = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    return ordersByRange(s, e).length;
  }

  double sumOrdersByYear(int year) {
    final s = DateTime(year, 1, 1);
    final e = DateTime(year, 12, 31, 23, 59, 59, 999);
    return ordersByRange(s, e).fold<double>(0, (p, o) => p + o.valor);
  }

  int countOrdersByYear(int year) {
    final s = DateTime(year, 1, 1);
    final e = DateTime(year, 12, 31, 23, 59, 59, 999);
    return ordersByRange(s, e).length;
  }

  double sumExpensesByYear(int year) {
    final s = DateTime(year, 1, 1);
    final e = DateTime(year, 12, 31, 23, 59, 59, 999);
    return expensesByRange(s, e).fold<double>(0, (p, x) => p + x.valor);
  }
}
