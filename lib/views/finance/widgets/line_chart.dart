import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../../viewmodels/finance_view_model.dart';

class LineChart extends StatelessWidget {
  final List<MonthPoint> series;
  final FinanceMode mode;
  final DateTime current;
  const LineChart({super.key, required this.series, required this.mode, required this.current});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(series, mode, current),
      child: const SizedBox(height: 140),
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
    const leftPad = 36.0;
    const bottomPad = 48.0;
    const topPad = 6.0;
    const rightPad = 8.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    final origin = Offset(leftPad, size.height - bottomPad);

    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    canvas.drawLine(origin, Offset(leftPad, topPad), axisPaint);
    canvas.drawLine(origin, Offset(size.width - rightPad, size.height - bottomPad), axisPaint);

    double maxVal = (series.map((e) => e.vendas).followedBy(series.map((e) => e.gastos)).fold<double>(0, (p, e) => e > p ? e : p));
    if (maxVal <= 0) maxVal = 1;

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

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final labelStyle = const TextStyle(fontSize: 9, color: Colors.grey);
    for (int i = 0; i <= 2; i++) {
      final t = i / 2;
      final y = origin.dy - t * chartHeight;
      final val = (maxVal * t);
      textPainter.text = TextSpan(text: _compact(val), style: labelStyle);
      textPainter.layout(minWidth: 0, maxWidth: leftPad - 4);
      textPainter.paint(canvas, Offset(leftPad - textPainter.width - 4, y - textPainter.height / 2));
      final gridPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.2)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width - rightPad, y), gridPaint);
    }

    if (series.length > 1) {
      if (mode == FinanceMode.monthly) {
        final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
        final lastTick = daysInMonth >= 30 ? 30 : daysInMonth;
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

    final legendStyle = const TextStyle(fontSize: 10, color: Colors.black87);
    final legendY = origin.dy + 30;
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
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (v >= 100) return v.toStringAsFixed(0);
    if (v >= 10) return v.toStringAsFixed(1);
    return v.toStringAsFixed(2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
