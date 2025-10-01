import 'package:delicias_da_may/core/enums.dart';
import 'package:delicias_da_may/models/client.dart';
import 'package:delicias_da_may/models/expense.dart';
import 'package:delicias_da_may/models/order.dart';
import 'package:delicias_da_may/models/product.dart';
import 'package:delicias_da_may/repositories/client_repository.dart';
import 'package:delicias_da_may/repositories/expense_repository.dart';
import 'package:delicias_da_may/repositories/order_repository.dart';
import 'package:delicias_da_may/repositories/product_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:delicias_da_may/data/data_cache.dart';

class DayCardItem {
  final String title; // Vendas: Cliente + Endereço; Gastos: Categoria
  final String subtitle; // Produto (para vendas)
  final double valor; // Valor ou gasto
  final bool isExpense;
  final DateTime time;
  final int? orderId;
  final int? expenseId;

  DayCardItem({
    required this.title,
    required this.subtitle,
    required this.valor,
    required this.isExpense,
    required this.time,
    this.orderId,
    this.expenseId,
  });
}

class OrderDetails {
  final Order order;
  final Client? client;
  final Product? product;
  OrderDetails({required this.order, this.client, this.product});
}

class CalendarViewModel extends ChangeNotifier {
  final OrderRepository orderRepo;
  final ExpenseRepository expenseRepo;
  final ClientRepository clientRepo;
  final ProductRepository productRepo;

  CalendarViewModel({
    required this.orderRepo,
    required this.expenseRepo,
    required this.clientRepo,
    required this.productRepo,
  });

  DateTime _selectedDay = DateTime.now();
  List<DayCardItem> _items = [];
  bool _loading = false;
  List<Client> _clients = [];
  List<Product> _products = [];

  DateTime get selectedDay => _selectedDay;
  List<DayCardItem> get items => _items;
  bool get loading => _loading;
  List<Client> get clients => _clients;
  List<Product> get products => _products;
  List<PaymentMethod> get paymentMethods => PaymentMethod.values;
  List<ExpenseCategory> get expenseCategories => ExpenseCategory.values;

  Future<void> init() async {
    await DataCache.instance.ensureLoaded(
      clientsRepo: clientRepo,
      productsRepo: productRepo,
      ordersRepo: orderRepo,
      expensesRepo: expenseRepo,
    );
    await loadForDay(_selectedDay);
    await reloadOptions();
  }

  Future<void> selectDay(DateTime day) async {
    _selectedDay = day;
    await loadForDay(day);
  }

  Future<void> loadForDay(DateTime day) async {
    _loading = true;
    notifyListeners();
    // Read from cache instead of hitting Firestore
    final orders = DataCache.instance.ordersByDate(day);
    final expenses = DataCache.instance.expensesByDate(day);

    final items = <DayCardItem>[];

    for (final o in orders) {
      final client = await clientRepo.getById(o.clienteId);
      final title = client != null ? '${client.nome} • ${client.endereco}' : 'Cliente #${o.clienteId}';
      final product = await productRepo.getById(o.produtoId);
      items.add(DayCardItem(
        title: title,
        subtitle: product?.nome ?? 'Produto',
        valor: o.valor,
        isExpense: false,
        time: o.time,
        orderId: o.id,
      ));
    }

    for (final e in expenses) {
      items.add(DayCardItem(
        title: e.categoria.label,
        subtitle: 'Gasto',
        valor: e.valor,
        isExpense: true,
        time: e.time,
        expenseId: e.id,
      ));
    }

    items.sort((a, b) => b.time.compareTo(a.time));

    _items = items;
    _loading = false;
    notifyListeners();
  }

  // Fetch single entries for editing
  Future<Order?> getOrder(int id) => orderRepo.getById(id);
  Future<Expense?> getExpense(int id) => expenseRepo.getById(id);

  // Fetch enriched details for display
  Future<OrderDetails?> getOrderDetails(int id) async {
    final order = await orderRepo.getById(id);
    if (order == null) return null;
    final client = await clientRepo.getById(order.clienteId);
    final product = await productRepo.getById(order.produtoId);
    return OrderDetails(order: order, client: client, product: product);
  }

  // Delete and Update operations
  Future<void> deleteOrder(int id) async {
    await orderRepo.delete(id);
    DataCache.instance.deleteOrder(id);
    await loadForDay(_selectedDay);
  }

  Future<void> deleteExpense(int id) async {
    await expenseRepo.delete(id);
    DataCache.instance.deleteExpense(id);
    await loadForDay(_selectedDay);
  }

  Future<void> updateOrder(Order order) async {
    await orderRepo.update(order);
    DataCache.instance.updateOrder(order);
    await loadForDay(_selectedDay);
  }

  Future<void> updateExpense(Expense expense) async {
    await expenseRepo.update(expense);
    DataCache.instance.updateExpense(expense);
    await loadForDay(_selectedDay);
  }

  Future<void> reloadOptions() async {
    _clients = DataCache.instance.clients;
    _products = DataCache.instance.products;
    notifyListeners();
  }

  // Create operations
  Future<void> addOrder({
    required int clienteId,
    required int produtoId,
    required double valor,
    int quantidade = 1,
    required PaymentMethod pagamento,
    DateTime? time,
  }) async {
    final when = time ?? DateTime.now();
    final order = Order(
      clienteId: clienteId,
      produtoId: produtoId,
      valor: valor,
      quantidade: quantidade,
      pagamento: pagamento,
      time: when,
    );
    await orderRepo.insert(order);
    DataCache.instance.addOrder(order);
    await loadForDay(_selectedDay);
  }

  Future<void> addExpense({
    required ExpenseCategory categoria,
    required double valor,
    required PaymentMethod pagamento,
    DateTime? time,
  }) async {
    final when = time ?? DateTime.now();
    final expense = Expense(
      categoria: categoria,
      valor: valor,
      pagamento: pagamento,
      time: when,
    );
    await expenseRepo.insert(expense);
    DataCache.instance.addExpense(expense);
    await loadForDay(_selectedDay);
  }

  // Allow other screens to force refresh of options when they change clients/products
  Future<void> externalOptionsUpdated() => reloadOptions();
}
