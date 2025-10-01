import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:delicias_da_may/core/app_colors.dart';
import 'package:delicias_da_may/viewmodels/finance_view_model.dart';
import 'finance/widgets/line_chart.dart';
import 'finance/widgets/stats_row.dart';
import 'finance/widgets/chart_cards.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo Financeiro')),
      body: RefreshIndicator(
        onRefresh: () async {
          await vm.refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ChartCard(
              series: vm.monthlySeries,
              mode: vm.mode,
              current: vm.current,
              headerLabel: vm.currentLabel,
              onToggleLabel: vm.toggleMode,
              onPrev: vm.previousPeriod,
              onNext: vm.nextPeriod,
              lucroText: currency.format(vm.lucro),
              ganhosText: currency.format(vm.totalVendas),
              gastosText: currency.format(vm.totalGastos),
              vendasCount: vm.vendasCount,
            ),
            const SizedBox(height: 16),
            const ProductQuantityChartCard(),
            const SizedBox(height: 16),
            const ProductValueChartCard(),
            const SizedBox(height: 16),
            const ExpenseValueChartCard(),
            const SizedBox(height: 16),
            const SalesPaymentValueChartCard(),
            const SizedBox(height: 16),
            const ExpensePaymentValueChartCard(),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<MonthPoint> series;
  final FinanceMode mode;
  final DateTime current;
  final String headerLabel;
  final VoidCallback onToggleLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final String lucroText;
  final String ganhosText;
  final String gastosText;
  final int vendasCount;
  const _ChartCard({
    required this.series,
    required this.mode,
    required this.current,
    required this.headerLabel,
    required this.onToggleLabel,
    required this.onPrev,
    required this.onNext,
    required this.lucroText,
    required this.ganhosText,
    required this.gastosText,
    required this.vendasCount,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.begeClaro,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: AppColors.marromChocolate,
                  onPressed: onPrev,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onToggleLabel,
                    child: Text(
                      headerLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.marromChocolate),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: AppColors.marromChocolate,
                  onPressed: onNext,
                ),
              ],
            ),
            const SizedBox(height: 8),
            StatsRow(ganhosText: ganhosText, gastosText: gastosText, lucroText: lucroText),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(
                lucroText,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.dourado),
              ),
            ),
            const SizedBox(height: 4),
            Text('$vendasCount Vendas', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            SizedBox(height: 140, child: LineChart(series: series, mode: mode, current: current)),
          ],
        ),
      ),
    );
  }
}
