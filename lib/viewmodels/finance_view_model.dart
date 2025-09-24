import 'package:delicias_da_may/repositories/expense_repository.dart';
import 'package:delicias_da_may/repositories/order_repository.dart';
import 'package:flutter/foundation.dart';

class MonthPoint {
  final double vendas;
  final double gastos;
  MonthPoint({required this.vendas, required this.gastos});
}

enum FinanceMode { monthly, yearly }

class FinanceViewModel extends ChangeNotifier {
  final OrderRepository orderRepository;
  final ExpenseRepository expenseRepository;

  FinanceViewModel({required this.orderRepository, required this.expenseRepository});

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

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    if (mode == FinanceMode.monthly) {
      totalVendas = await orderRepository.sumByMonth(currentYear, currentMonth);
      totalGastos = await expenseRepository.sumByMonth(currentYear, currentMonth);
      vendasCount = await orderRepository.countByMonth(currentYear, currentMonth);

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
      totalVendas = await orderRepository.sumByYear(currentYear);
      totalGastos = await expenseRepository.sumByYear(currentYear);
      vendasCount = await orderRepository.countByYear(currentYear);

      final List<MonthPoint> s = [];
      for (int m = 1; m <= 12; m++) {
        final v = await orderRepository.sumByMonth(currentYear, m);
        final g = await expenseRepository.sumByMonth(currentYear, m);
        s.add(MonthPoint(vendas: v, gastos: g));
      }
      monthlySeries = s;
    }
    notifyListeners();
  }

  void toggleMode() {
    mode = mode == FinanceMode.monthly ? FinanceMode.yearly : FinanceMode.monthly;
    notifyListeners();
    refresh();
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

  String _monthName(int m) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[(m - 1).clamp(0, 11)];
  }
}
