import 'package:delicias_da_may/core/app_colors.dart';
import 'package:delicias_da_may/viewmodels/finance_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:delicias_da_may/data/firestore_backup.dart';
import 'package:delicias_da_may/viewmodels/calendar_view_model.dart';
import 'package:delicias_da_may/viewmodels/clients_view_model.dart';
import 'package:delicias_da_may/viewmodels/products_view_model.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo Financeiro'),
        leading: IconButton(
          tooltip: 'Importar JSON',
          icon: const Icon(Icons.folder_open),
          onPressed: () async {
            try {
              // Try to read from the same place we save: Downloads, then Documents
              File? file;
              try {
                final dir = await getDownloadsDirectory();
                if (dir != null) {
                  final f = File('${dir.path}/delicias_da_may_backup.json');
                  if (await f.exists()) file = f;
                }
              } catch (_) {}
              if (file == null) {
                final docs = await getApplicationDocumentsDirectory();
                final f = File('${docs.path}/delicias_da_may_backup.json');
                if (await f.exists()) file = f;
              }
              if (file == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arquivo de backup não encontrado')));
                }
                return;
              }
              final content = await file.readAsString();
              await FirestoreBackup().importJson(content);
              // Refresh all viewmodels so UI reflects imported data
              if (context.mounted) {
                final calendar = context.read<CalendarViewModel>();
                final clients = context.read<ClientsViewModel>();
                final products = context.read<ProductsViewModel>();
                final finance = context.read<FinanceViewModel>();
                await Future.wait([
                  clients.refresh(),
                  products.refresh(),
                  // reload day items and options
                  calendar.reloadOptions().then((_) => calendar.loadForDay(calendar.selectedDay)),
                  finance.refresh(),
                ]);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Base importada com sucesso')));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao importar: $e')));
              }
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Salvar JSON',
            icon: const Icon(Icons.save_alt),
            onPressed: () async {
              try {
                final json = await FirestoreBackup().exportJson();
                final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
                final file = File('${dir.path}/delicias_da_may_backup.json');
                await file.writeAsString(json);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Arquivo salvo em: ${file.path}')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao salvar: $e')));
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.refresh,
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
    // Simple custom line chart using CustomPainter (no external deps)
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
            _StatsRow(ganhosText: ganhosText, gastosText: gastosText, lucroText: lucroText),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(
                lucroText,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.dourado),
              ),
            ),
            const SizedBox(height: 4),
            Text('${vendasCount} Vendas', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: CustomPaint(
                painter: _LineChartPainter(series, mode, current),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<MonthPoint> series;
  final FinanceMode mode;
  final DateTime current;
  _LineChartPainter(this.series, this.mode, this.current);
  @override
  void paint(Canvas canvas, Size size) {
    final paintSales = Paint()
      ..color = Colors.amber
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paintExpenses = Paint()
      ..color = Colors.brown
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    // Layout paddings
  const leftPad = 36.0; // for Y labels
  const bottomPad = 48.0; // increased spacing for X labels + legend
  const topPad = 6.0; // smaller top to make flatter
    const rightPad = 8.0;

  final chartWidth = size.width - leftPad - rightPad;
  final chartHeight = size.height - topPad - bottomPad;
    final origin = Offset(leftPad, size.height - bottomPad);

    // Axes
    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    // Y axis
    canvas.drawLine(origin, Offset(leftPad, topPad), axisPaint);
    // X axis
    canvas.drawLine(origin, Offset(size.width - rightPad, size.height - bottomPad), axisPaint);

    // Max value for scaling
    double maxVal = (series.map((e) => e.vendas).followedBy(series.map((e) => e.gastos)).fold<double>(0, (p, e) => e > p ? e : p));
    if (maxVal <= 0) maxVal = 1; // avoid div by zero, flat lines

    // Build paths
    final dx = chartWidth / ((series.length - 1).clamp(1, double.infinity));
    Path p1 = Path();
    Path p2 = Path();
    for (int i = 0; i < series.length; i++) {
      final x = origin.dx + dx * i;
  final ySales = origin.dy - (series[i].vendas / maxVal) * chartHeight;
  final yExp = origin.dy - (series[i].gastos / maxVal) * chartHeight;
      if (i == 0) {
        p1.moveTo(x, ySales);
        p2.moveTo(x, yExp);
      } else {
        p1.lineTo(x, ySales);
        p2.lineTo(x, yExp);
      }
    }
    canvas.drawPath(p1, paintSales);
    canvas.drawPath(p2, paintExpenses);

    // Y-axis labels (small)
  final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final labelStyle = const TextStyle(fontSize: 9, color: Colors.grey);
    for (int i = 0; i <= 2; i++) {
      final t = i / 2; // 0, 0.5, 1
      final y = origin.dy - t * chartHeight;
      final val = (maxVal * t);
      textPainter.text = TextSpan(text: _compact(val), style: labelStyle);
      textPainter.layout(minWidth: 0, maxWidth: leftPad - 4);
      textPainter.paint(canvas, Offset(leftPad - textPainter.width - 4, y - textPainter.height / 2));
      // grid line
      final gridPaint = Paint()
        ..color = Colors.grey.withOpacity(0.2)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width - rightPad, y), gridPaint);
    }

    // X-axis labels depending on mode
    if (series.length > 1) {
      if (mode == FinanceMode.monthly) {
        final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
        final lastTick = daysInMonth >= 30 ? 30 : daysInMonth; // 28/29/30
        final ticks = <int>{5, 10, 15, 20, 25, lastTick}
            .where((d) => d >= 1 && d <= daysInMonth)
            .toList()
          ..sort();
        for (final day in ticks) {
          final i = (day - 1).clamp(0, series.length - 1);
          final x = origin.dx + dx * i;
          final tp = TextPainter(
            text: TextSpan(text: '$day', style: labelStyle),
            textDirection: ui.TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(x - tp.width / 2, origin.dy + 4));
        }
      } else {
        // yearly: 12 points, show Jan, Mar, Mai, Jul, Set, Nov
        const monthsIdx = [1, 3, 5, 7, 9, 11];
        const monthsAbbr = ['Jan', 'Mar', 'Mai', 'Jul', 'Set', 'Nov'];
        for (int k = 0; k < monthsIdx.length; k++) {
          final m = monthsIdx[k];
          final i = (m - 1).clamp(0, series.length - 1);
          final x = origin.dx + dx * i;
          final tp = TextPainter(
            text: TextSpan(text: monthsAbbr[k], style: labelStyle),
            textDirection: ui.TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(x - tp.width / 2, origin.dy + 4));
        }
      }
    }

    // Legend at bottom-left (small, dots)
  final legendStyle = const TextStyle(fontSize: 10, color: Colors.black87);
  final legendY = origin.dy + 30; // even more spacing from x-axis
    double lx = leftPad;
    void drawLegendDot(Color c, String text) {
      final dotPaint = Paint()..color = c;
      canvas.drawCircle(Offset(lx + 4, legendY - 4), 3, dotPaint);
      final tp = TextPainter(
        text: TextSpan(text: ' $text', style: legendStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lx + 10, legendY - tp.height));
      lx += 10 + tp.width + 16;
    }
    drawLegendDot(paintSales.color, 'Ganhos');
    drawLegendDot(paintExpenses.color, 'Gastos');
  }

  String _compact(double v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(1)}M';
    }
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}k';
    }
    if (v >= 100) {
      return v.toStringAsFixed(0);
    }
    if (v >= 10) {
      return v.toStringAsFixed(1);
    }
    return v.toStringAsFixed(2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatsRow extends StatelessWidget {
  final String ganhosText;
  final String gastosText;
  final String lucroText;
  const _StatsRow({required this.ganhosText, required this.gastosText, required this.lucroText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatsBlock(
          title: 'Ganhos',
          value: ganhosText,
          background: const Color(0xFFF4C430), // amarelo mais vivo como no mock
          titleColor: Colors.white,
          valueColor: Colors.white,
          outlined: false,
        ),
        const SizedBox(width: 8),
        _StatsBlock(
          title: 'Gastos',
          value: gastosText,
          background: AppColors.marromChocolate,
          titleColor: Colors.white,
          valueColor: Colors.white,
          outlined: false,
        ),
        const SizedBox(width: 8),
        _StatsBlock(
          title: 'Lucro',
          value: lucroText,
          background: AppColors.begeClaro,
          titleColor: AppColors.marromChocolate,
          valueColor: AppColors.marromChocolate,
          outlined: true,
        ),
      ],
    );
  }
}

class _StatsBlock extends StatelessWidget {
  final String title;
  final String value;
  final Color background;
  final Color titleColor;
  final Color valueColor;
  final bool outlined;
  const _StatsBlock({
    required this.title,
    required this.value,
    required this.background,
    required this.titleColor,
    required this.valueColor,
    required this.outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: outlined ? Border.all(color: const Color(0xFFF4C430), width: 2) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18, // cabe até R$ 9.999,99
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
