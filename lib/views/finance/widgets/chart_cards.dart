import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../viewmodels/finance_view_model.dart';
import 'common.dart';
import 'painters.dart';
import 'legends.dart';

class ProductQuantityChartCard extends StatelessWidget {
  const ProductQuantityChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final data = vm.productQuantities;
    final colors = buildColors(data.length);
    return Card(
      color: AppColors.begeClaro,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Quantidade Produto',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.marromChocolate),
            ),
            const SizedBox(height: 30),
            if (data.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Sem vendas no período', textAlign: TextAlign.center),
              )
            else
              GestureDetector(
                onTap: vm.toggleChartType,
                child: SizedBox(
                  height: 220,
          child: vm.showPieChart
            ? CustomPaint(painter: PieChartQtyPainter(data, colors))
            : CustomPaint(painter: BarChartQtyPainter(data, colors)),
                ),
              ),
            if (data.isNotEmpty) ...[
              const SizedBox(height: 12),
              LegendProductQty(data: data, colors: colors),
            ]
          ],
        ),
      ),
    );
  }
}

class ProductValueChartCard extends StatelessWidget {
  const ProductValueChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final data = vm.productValues;
    final colors = buildColors(data.length);
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Card(
      color: AppColors.begeClaro,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Valor Produto',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.marromChocolate),
            ),
            const SizedBox(height: 30),
            if (data.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Sem vendas no período', textAlign: TextAlign.center),
              )
            else
              GestureDetector(
                onTap: vm.toggleChartTypeValue,
                child: SizedBox(
                  height: 220,
          child: vm.showPieChartValue
            ? CustomPaint(painter: PieChartValuePainter(data, colors, currency))
            : CustomPaint(painter: BarChartValuePainter(data, colors, currency)),
                ),
              ),
            if (data.isNotEmpty) ...[
              const SizedBox(height: 12),
              LegendProductValue(data: data, colors: colors),
            ]
          ],
        ),
      ),
    );
  }
}

class ExpenseValueChartCard extends StatelessWidget {
  const ExpenseValueChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final data = vm.expenseValues;
    final colors = buildColors(data.length);
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Card(
      color: AppColors.begeClaro,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Valor Gasto',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.marromChocolate),
            ),
            const SizedBox(height: 30),
            if (data.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Sem gastos no período', textAlign: TextAlign.center),
              )
            else
              GestureDetector(
                onTap: vm.toggleChartTypeExpense,
                child: SizedBox(
                  height: 220,
          child: vm.showPieChartExpense
            ? CustomPaint(painter: PieChartCategoryValuePainter(data, colors, currency))
            : CustomPaint(painter: BarChartCategoryValuePainter(data, colors, currency)),
                ),
              ),
            if (data.isNotEmpty) ...[
              const SizedBox(height: 12),
              LegendCategoryValue(data: data, colors: colors),
            ]
          ],
        ),
      ),
    );
  }
}

class SalesPaymentValueChartCard extends StatelessWidget {
  const SalesPaymentValueChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final data = vm.salesPaymentValues;
    final colors = buildColors(data.length);
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Card(
      color: AppColors.begeClaro,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Valor Pagamento venda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.marromChocolate),
            ),
            const SizedBox(height: 30),
            if (data.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Sem vendas no período', textAlign: TextAlign.center),
              )
            else
              GestureDetector(
                onTap: vm.toggleChartTypePaymentSales,
                child: SizedBox(
                  height: 220,
          child: vm.showPieChartPaymentSales
            ? CustomPaint(painter: PieChartPaymentValuePainter(data, colors, currency))
            : CustomPaint(painter: BarChartPaymentValuePainter(data, colors, currency)),
                ),
              ),
            if (data.isNotEmpty) ...[
              const SizedBox(height: 12),
              LegendPaymentValue(data: data, colors: colors, currency: currency),
            ]
          ],
        ),
      ),
    );
  }
}

class ExpensePaymentValueChartCard extends StatelessWidget {
  const ExpensePaymentValueChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final data = vm.expensePaymentValues;
    final colors = buildColors(data.length);
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Card(
      color: AppColors.begeClaro,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Valor Pagamento gasto',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.marromChocolate),
            ),
            const SizedBox(height: 30),
            if (data.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Sem gastos no período', textAlign: TextAlign.center),
              )
            else
              GestureDetector(
                onTap: vm.toggleChartTypePaymentExpense,
                child: SizedBox(
                  height: 220,
          child: vm.showPieChartPaymentExpense
            ? CustomPaint(painter: PieChartPaymentValuePainter(data, colors, currency))
            : CustomPaint(painter: BarChartPaymentValuePainter(data, colors, currency)),
                ),
              ),
            if (data.isNotEmpty) ...[
              const SizedBox(height: 12),
              LegendPaymentValue(data: data, colors: colors, currency: currency),
            ]
          ],
        ),
      ),
    );
  }
}

// Legends imported from legends.dart
