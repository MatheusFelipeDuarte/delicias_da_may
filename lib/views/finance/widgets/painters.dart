import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../viewmodels/finance_view_model.dart';
import 'common.dart';

class PieChartQtyPainter extends CustomPainter {
  final List<ProductQty> data;
  final List<Color> colors;
  PieChartQtyPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<int>(0, (p, e) => p + e.quantity);
    if (total <= 0) return;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height - 40);
    final radius = (rect.shortestSide * 0.45);
    final center = Offset(size.width / 2, rect.top + rect.height / 2);

    double startAngle = -math.pi / 2;
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr)..maxLines = 1;
    final labelStyle = const TextStyle(fontSize: 9, color: Colors.black87);

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final sweep = (d.quantity / total) * (math.pi * 2);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, true, paint);

      final midAngle = startAngle + sweep / 2;
      final edge = center + Offset(radius * math.cos(midAngle), radius * math.sin(midAngle));
      final guideEnd = center + Offset(radius * 1.22 * math.cos(midAngle), radius * 1.22 * math.sin(midAngle));
      final labelPos = center + Offset(radius * 1.45 * math.cos(midAngle), radius * 1.45 * math.sin(midAngle));
      final guide = Paint()
        ..color = Colors.black26
        ..strokeWidth = 1;
      canvas.drawLine(edge, guideEnd, guide);
      textPainter.text = TextSpan(text: '${d.quantity}', style: labelStyle);
      textPainter.layout();
      canvas.save();
      canvas.translate(labelPos.dx - textPainter.width / 2, labelPos.dy - textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartValuePainter extends CustomPainter {
  final List<ProductValue> data;
  final List<Color> colors;
  final NumberFormat currency;
  PieChartValuePainter(this.data, this.colors, this.currency);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<double>(0, (p, e) => p + e.value);
    if (total <= 0) return;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height - 40);
    final radius = (rect.shortestSide * 0.45);
    final center = Offset(size.width / 2, rect.top + rect.height / 2);

    double startAngle = -math.pi / 2;
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final labelStyle = const TextStyle(fontSize: 10, color: Colors.black87);

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final sweep = (d.value / total) * (math.pi * 2);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, true, paint);

      final midAngle = startAngle + sweep / 2;
      final edge = center + Offset(radius * math.cos(midAngle), radius * math.sin(midAngle));
      final guideEnd = center + Offset(radius * 1.22 * math.cos(midAngle), radius * 1.22 * math.sin(midAngle));
      final labelPos = center + Offset(radius * 1.45 * math.cos(midAngle), radius * 1.45 * math.sin(midAngle));
      final guide = Paint()
        ..color = Colors.black26
        ..strokeWidth = 1;
      canvas.drawLine(edge, guideEnd, guide);

      textPainter.text = TextSpan(text: compactCurrency(d.value), style: labelStyle);
      textPainter.layout();
      canvas.save();
      canvas.translate(labelPos.dx - textPainter.width / 2, labelPos.dy - textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartCategoryValuePainter extends CustomPainter {
  final List<CategoryValue> data;
  final List<Color> colors;
  final NumberFormat currency;
  PieChartCategoryValuePainter(this.data, this.colors, this.currency);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<double>(0, (p, e) => p + e.value);
    if (total <= 0) return;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height - 40);
    final radius = (rect.shortestSide * 0.45);
    final center = Offset(size.width / 2, rect.top + rect.height / 2);

    double startAngle = -math.pi / 2;
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr)..maxLines = 1;
    final labelStyle = const TextStyle(fontSize: 9, color: Colors.black87);

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final sweep = (d.value / total) * (math.pi * 2);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, true, paint);

      final midAngle = startAngle + sweep / 2;
      final edge = center + Offset(radius * math.cos(midAngle), radius * math.sin(midAngle));
      final guideEnd = center + Offset(radius * 1.22 * math.cos(midAngle), radius * 1.22 * math.sin(midAngle));
      final labelPos = center + Offset(radius * 1.45 * math.cos(midAngle), radius * 1.45 * math.sin(midAngle));
      final guide = Paint()
        ..color = Colors.black26
        ..strokeWidth = 1;
      canvas.drawLine(edge, guideEnd, guide);

      textPainter.text = TextSpan(text: compactCurrency(d.value), style: labelStyle);
      textPainter.layout();
      canvas.save();
      canvas.translate(labelPos.dx - textPainter.width / 2, labelPos.dy - textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartPaymentValuePainter extends CustomPainter {
  final List<PaymentValue> data;
  final List<Color> colors;
  final NumberFormat currency;
  PieChartPaymentValuePainter(this.data, this.colors, this.currency);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<double>(0, (p, e) => p + e.value);
    if (total <= 0) return;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height - 40);
    final radius = (rect.shortestSide * 0.45);
    final center = Offset(size.width / 2, rect.top + rect.height / 2);

    double startAngle = -math.pi / 2;
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr)..maxLines = 1;
    final labelStyle = const TextStyle(fontSize: 9, color: Colors.black87);

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final sweep = (d.value / total) * (math.pi * 2);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, true, paint);

      final midAngle = startAngle + sweep / 2;
      final edge = center + Offset(radius * math.cos(midAngle), radius * math.sin(midAngle));
      final guideEnd = center + Offset(radius * 1.22 * math.cos(midAngle), radius * 1.22 * math.sin(midAngle));
      final labelPos = center + Offset(radius * 1.45 * math.cos(midAngle), radius * 1.45 * math.sin(midAngle));
      final guide = Paint()
        ..color = Colors.black26
        ..strokeWidth = 1;
      canvas.drawLine(edge, guideEnd, guide);

      textPainter.text = TextSpan(text: compactCurrency(d.value), style: labelStyle);
      textPainter.layout();
      canvas.save();
      canvas.translate(labelPos.dx - textPainter.width / 2, labelPos.dy - textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartPaymentValuePainter extends CustomPainter {
  final List<PaymentValue> data;
  final List<Color> colors;
  final NumberFormat currency;
  BarChartPaymentValuePainter(this.data, this.colors, this.currency);

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = data.fold<double>(0, (p, e) => e.value > p ? e.value : p);
    if (maxV <= 0) return;
    const leftPad = 0.0;
    const rightPad = 0.0;
    const topPad = 8.0;
    const bottomPad = 30.0;
    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    final origin = Offset(leftPad, size.height - bottomPad);

    final barPaint = Paint()..style = PaintingStyle.fill;

    final barCount = data.length;
    final barSpace = chartWidth / barCount;
    final barWidth = barSpace * 0.75;

    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    canvas.drawLine(origin, Offset(leftPad, topPad), axisPaint);
    canvas.drawLine(origin, Offset(size.width - rightPad, origin.dy), axisPaint);

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      barPaint.color = colors[i % colors.length];
      final h = (d.value / maxV) * chartHeight;
      final x = origin.dx + i * barSpace + (barSpace - barWidth) / 2;
      final y = origin.dy - h;
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barWidth, h), const Radius.circular(6));
      canvas.drawRRect(r, barPaint);

      final text = compactCurrency(d.value);
      final tp = TextPainter(textDirection: ui.TextDirection.ltr)
        ..maxLines = 1
        ..text = TextSpan(text: text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black87));
      tp.layout();
      final yAbove = (y - tp.height - 8).clamp(0.0, double.infinity);
      tp.paint(canvas, Offset(x + (barWidth - tp.width) / 2, yAbove));

      final bt = TextPainter(textDirection: ui.TextDirection.ltr)
        ..maxLines = 1
        ..text = TextSpan(text: text, style: const TextStyle(fontSize: 9));
      bt.layout();
      bt.paint(canvas, Offset(origin.dx + i * barSpace + (barSpace - bt.width) / 2, origin.dy + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartQtyPainter extends CustomPainter {
  final List<ProductQty> data;
  final List<Color> colors;
  BarChartQtyPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final maxQ = data.fold<int>(0, (p, e) => e.quantity > p ? e.quantity : p);
    if (maxQ <= 0) return;
    const leftPad = 0.0;
    const rightPad = 0.0;
    const topPad = 8.0;
    const bottomPad = 30.0;
    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    final origin = Offset(leftPad, size.height - bottomPad);

    final barPaint = Paint()..style = PaintingStyle.fill;

    final barCount = data.length;
    final barSpace = chartWidth / barCount;
    final barWidth = barSpace * 0.75;

    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    canvas.drawLine(origin, Offset(leftPad, topPad), axisPaint);
    canvas.drawLine(origin, Offset(size.width - rightPad, origin.dy), axisPaint);

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      barPaint.color = colors[i % colors.length];
      final h = (d.quantity / maxQ) * chartHeight;
      final x = origin.dx + i * barSpace + (barSpace - barWidth) / 2;
      final y = origin.dy - h;
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barWidth, h), const Radius.circular(6));
      canvas.drawRRect(r, barPaint);

      final tp = TextPainter(textDirection: ui.TextDirection.ltr)
        ..maxLines = 1
        ..text = TextSpan(text: '${d.quantity}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black87));
      tp.layout();
      final yAbove = (y - tp.height - 8).clamp(0.0, double.infinity);
      tp.paint(canvas, Offset(x + (barWidth - tp.width) / 2, yAbove));

      final bottomTp = TextPainter(textDirection: ui.TextDirection.ltr)
        ..text = TextSpan(text: '${d.quantity}', style: const TextStyle(fontSize: 10));
      bottomTp.layout();
      final bx = origin.dx + i * barSpace + (barSpace - bottomTp.width) / 2;
      bottomTp.paint(canvas, Offset(bx, origin.dy + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartValuePainter extends CustomPainter {
  final List<ProductValue> data;
  final List<Color> colors;
  final NumberFormat currency;
  BarChartValuePainter(this.data, this.colors, this.currency);

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = data.fold<double>(0, (p, e) => e.value > p ? e.value : p);
    if (maxV <= 0) return;
    const leftPad = 0.0;
    const rightPad = 0.0;
    const topPad = 8.0;
    const bottomPad = 30.0;
    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    final origin = Offset(leftPad, size.height - bottomPad);

    final barPaint = Paint()..style = PaintingStyle.fill;

    final barCount = data.length;
    final barSpace = chartWidth / barCount;
    final barWidth = barSpace * 0.75;

    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    canvas.drawLine(origin, Offset(leftPad, topPad), axisPaint);
    canvas.drawLine(origin, Offset(size.width - rightPad, origin.dy), axisPaint);

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      barPaint.color = colors[i % colors.length];
      final h = (d.value / maxV) * chartHeight;
      final x = origin.dx + i * barSpace + (barSpace - barWidth) / 2;
      final y = origin.dy - h;
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barWidth, h), const Radius.circular(6));
      canvas.drawRRect(r, barPaint);

      final text = compactCurrency(d.value);
      final tp = TextPainter(textDirection: ui.TextDirection.ltr)
        ..maxLines = 1
        ..text = TextSpan(text: text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black87));
      tp.layout();
      final yAbove = (y - tp.height - 8).clamp(0.0, double.infinity);
      tp.paint(canvas, Offset(x + (barWidth - tp.width) / 2, yAbove));

      final bt = TextPainter(textDirection: ui.TextDirection.ltr)
        ..maxLines = 1
        ..text = TextSpan(text: text, style: const TextStyle(fontSize: 9));
      bt.layout();
      bt.paint(canvas, Offset(origin.dx + i * barSpace + (barSpace - bt.width) / 2, origin.dy + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartCategoryValuePainter extends CustomPainter {
  final List<CategoryValue> data;
  final List<Color> colors;
  final NumberFormat currency;
  BarChartCategoryValuePainter(this.data, this.colors, this.currency);

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = data.fold<double>(0, (p, e) => e.value > p ? e.value : p);
    if (maxV <= 0) return;
    const leftPad = 0.0;
    const rightPad = 0.0;
    const topPad = 8.0;
    const bottomPad = 30.0;
    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    final origin = Offset(leftPad, size.height - bottomPad);

    final barPaint = Paint()..style = PaintingStyle.fill;

    final barCount = data.length;
    final barSpace = chartWidth / barCount;
    final barWidth = barSpace * 0.75;

    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    canvas.drawLine(origin, Offset(leftPad, topPad), axisPaint);
    canvas.drawLine(origin, Offset(size.width - rightPad, origin.dy), axisPaint);

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      barPaint.color = colors[i % colors.length];
      final h = (d.value / maxV) * chartHeight;
      final x = origin.dx + i * barSpace + (barSpace - barWidth) / 2;
      final y = origin.dy - h;
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barWidth, h), const Radius.circular(6));
      canvas.drawRRect(r, barPaint);

      final text = compactCurrency(d.value);
      final tp = TextPainter(textDirection: ui.TextDirection.ltr)
        ..maxLines = 1
        ..text = TextSpan(text: text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black87));
      tp.layout();
      final yAbove = (y - tp.height - 8).clamp(0.0, double.infinity);
      tp.paint(canvas, Offset(x + (barWidth - tp.width) / 2, yAbove));

      final bt = TextPainter(textDirection: ui.TextDirection.ltr)
        ..maxLines = 1
        ..text = TextSpan(text: text, style: const TextStyle(fontSize: 9));
      bt.layout();
      bt.paint(canvas, Offset(origin.dx + i * barSpace + (barSpace - bt.width) / 2, origin.dy + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
