import 'package:delicias_da_may/repositories/expense_repository.dart';
import 'package:delicias_da_may/repositories/client_repository.dart';
import 'package:delicias_da_may/repositories/order_repository.dart';
import 'package:delicias_da_may/repositories/product_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:delicias_da_may/core/enums.dart';
import 'package:delicias_da_may/data/data_cache.dart';

class MonthPoint {
  final double vendas;
  final double gastos;
  MonthPoint({required this.vendas, required this.gastos});
}

enum FinanceMode { monthly, yearly }

class ProductQty {
  final int id;
  final String name;
  final int quantity;
  const ProductQty({required this.id, required this.name, required this.quantity});
}

class ProductValue {
  final int id;
  final String name;
  final double value;
  const ProductValue({required this.id, required this.name, required this.value});
}

class CategoryValue {
  final ExpenseCategory category;
  final String name;
  final double value;
  const CategoryValue({required this.category, required this.name, required this.value});
}

class PaymentValue {
  final PaymentMethod method;
  final String name;
  final double value;
  const PaymentValue({required this.method, required this.name, required this.value});
}

class FinanceViewModel extends ChangeNotifier {
  final OrderRepository orderRepository;
  final ExpenseRepository expenseRepository;
  final ProductRepository productRepository;

  FinanceViewModel({
    required this.orderRepository,
    required this.expenseRepository,
    required this.productRepository,
  });

  double totalVendas = 0;
  double totalGastos = 0;
  List<MonthPoint> monthlySeries = const [];
  FinanceMode mode = FinanceMode.monthly;
  DateTime current = DateTime.now();
  int get currentYear => current.year;
  int get currentMonth => current.month;
  String get currentLabel => mode == FinanceMode.monthly ? '${_monthName(currentMonth)} de $currentYear' : currentYear.toString();
  int vendasCount = 0;

  double get lucro => totalVendas - totalGastos;

  // Quantidade por produto no período atual
  Map<int, int> _qtyByProductId = {};
  Map<int, String> _productNames = {};
  bool showPieChart = true; // toggle pie <-> bar on tap
  // Valor por produto no período atual
  Map<int, double> _valueByProductId = {};
  bool showPieChartValue = true;
  // Valor gasto por categoria
  Map<ExpenseCategory, double> _valueByCategory = {};
  bool showPieChartExpense = true;
  // Valor por forma de pagamento (vendas)
  Map<PaymentMethod, double> _valueByPaymentSales = {};
  bool showPieChartPaymentSales = true;
  // Valor por forma de pagamento (gastos)
  Map<PaymentMethod, double> _valueByPaymentExpenses = {};
  bool showPieChartPaymentExpense = true;

  List<ProductQty> get productQuantities {
    final list = _qtyByProductId.entries
        .map((e) => ProductQty(
              id: e.key,
              name: _productNames[e.key] ?? 'Produto ${e.key}',
              quantity: e.value,
            ))
        .toList();
    // sort descending by quantity
    list.sort((a, b) => b.quantity.compareTo(a.quantity));
    return list;
  }

  List<ProductValue> get productValues {
    final list = _valueByProductId.entries
        .map((e) => ProductValue(
              id: e.key,
              name: _productNames[e.key] ?? 'Produto ${e.key}',
              value: e.value,
            ))
        .toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  List<CategoryValue> get expenseValues {
    final list = _valueByCategory.entries
        .map((e) => CategoryValue(category: e.key, name: e.key.label, value: e.value))
        .toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  List<PaymentValue> get salesPaymentValues {
    final list = _valueByPaymentSales.entries
        .map((e) => PaymentValue(method: e.key, name: e.key.label, value: e.value))
        .toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  List<PaymentValue> get expensePaymentValues {
    final list = _valueByPaymentExpenses.entries
        .map((e) => PaymentValue(method: e.key, name: e.key.label, value: e.value))
        .toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  Future<void> init() async {
    await DataCache.instance.ensureLoaded(
      clientsRepo: ClientRepository(),
      productsRepo: productRepository,
      ordersRepo: orderRepository,
      expensesRepo: expenseRepository,
    );
    await refresh();
  }

  Future<void> refresh() async {
    // Only hit Firestore when explicitly refreshing the cache
    await DataCache.instance.refreshAll(
      clientsRepo: ClientRepository(),
      productsRepo: productRepository,
      ordersRepo: orderRepository,
      expensesRepo: expenseRepository,
    );
    if (mode == FinanceMode.monthly) {
      totalVendas = DataCache.instance.sumOrdersByMonth(currentYear, currentMonth);
      totalGastos = DataCache.instance.sumExpensesByMonth(currentYear, currentMonth);
      vendasCount = DataCache.instance.countOrdersByMonth(currentYear, currentMonth);

      // Build daily series for the selected month
      final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
      final List<MonthPoint> s = [];
      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(currentYear, currentMonth, day);
        // Sum vendas and gastos for the day using existing date queries
        final orders = await orderRepository.getByDate(date);
        final expenses = await expenseRepository.getByDate(date);
        final v = orders.fold<double>(0, (p, e) => p + e.valor);
        final g = expenses.fold<double>(0, (p, e) => p + e.valor);
        s.add(MonthPoint(vendas: v, gastos: g));
      }
      monthlySeries = s;
    } else {
  totalVendas = DataCache.instance.sumOrdersByYear(currentYear);
  totalGastos = DataCache.instance.sumExpensesByYear(currentYear);
  vendasCount = DataCache.instance.countOrdersByYear(currentYear);

      final List<MonthPoint> s = [];
      for (int m = 1; m <= 12; m++) {
        final v = await orderRepository.sumByMonth(currentYear, m);
        final g = await expenseRepository.sumByMonth(currentYear, m);
        s.add(MonthPoint(vendas: v, gastos: g));
      }
      monthlySeries = s;
    }
    await _loadProductQuantitiesForCurrentPeriod();
    notifyListeners();
  }

  void toggleMode() {
    mode = mode == FinanceMode.monthly ? FinanceMode.yearly : FinanceMode.monthly;
    notifyListeners();
    refresh();
  }

  void toggleChartType() {
    showPieChart = !showPieChart;
    notifyListeners();
  }

  void toggleChartTypeValue() {
    showPieChartValue = !showPieChartValue;
    notifyListeners();
  }

  void toggleChartTypeExpense() {
    showPieChartExpense = !showPieChartExpense;
    notifyListeners();
  }

  void toggleChartTypePaymentSales() {
    showPieChartPaymentSales = !showPieChartPaymentSales;
    notifyListeners();
  }

  void toggleChartTypePaymentExpense() {
    showPieChartPaymentExpense = !showPieChartPaymentExpense;
    notifyListeners();
  }

  void nextPeriod() {
    if (mode == FinanceMode.monthly) {
      current = DateTime(current.year, current.month + 1, 1);
    } else {
      current = DateTime(current.year + 1, 1, 1);
    }
    notifyListeners();
    refresh();
  }

  void previousPeriod() {
    if (mode == FinanceMode.monthly) {
      current = DateTime(current.year, current.month - 1, 1);
    } else {
      current = DateTime(current.year - 1, 1, 1);
    }
    notifyListeners();
    refresh();
  }

  Future<void> _loadProductQuantitiesForCurrentPeriod() async {
    // Determine date range according to mode/current
    DateTime start;
    DateTime end;
    if (mode == FinanceMode.monthly) {
      start = DateTime(currentYear, currentMonth, 1);
      end = DateTime(currentYear, currentMonth + 1, 0, 23, 59, 59, 999);
    } else {
      start = DateTime(currentYear, 1, 1);
      end = DateTime(currentYear, 12, 31, 23, 59, 59, 999);
    }
  final orders = DataCache.instance.ordersByRange(start, end);
    final map = <int, int>{};
    final valMap = <int, double>{};
    final paySales = <PaymentMethod, double>{};
    for (final o in orders) {
      final pid = o.produtoId;
      final q = o.quantidade;
      map[pid] = (map[pid] ?? 0) + q;
      valMap[pid] = (valMap[pid] ?? 0) + o.valor;
      paySales[o.pagamento] = (paySales[o.pagamento] ?? 0) + o.valor;
    }
    _qtyByProductId = map;
    _valueByProductId = valMap;
    _valueByPaymentSales = paySales;
    // Load expenses by category for same period
  final expenses = DataCache.instance.expensesByRange(start, end);
    final catMap = <ExpenseCategory, double>{};
    final payExp = <PaymentMethod, double>{};
    for (final g in expenses) {
      final c = g.categoria;
      catMap[c] = (catMap[c] ?? 0) + g.valor;
      payExp[g.pagamento] = (payExp[g.pagamento] ?? 0) + g.valor;
    }
    _valueByCategory = catMap;
    _valueByPaymentExpenses = payExp;
    if (map.isNotEmpty) {
      final products = DataCache.instance.products;
      final byId = {for (final p in products) if (p.id != null) p.id!: p.nome};
      _productNames = {for (final id in map.keys) id: (byId[id] ?? 'Produto $id')};
    } else {
      _productNames = {};
    }
  }

  String _monthName(int m) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[(m - 1).clamp(0, 11)];
  }
}
