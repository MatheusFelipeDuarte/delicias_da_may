import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../viewmodels/finance_view_model.dart';

class LegendProductQty extends StatelessWidget {
  final List<ProductQty> data;
  final List<Color> colors;
  const LegendProductQty({super.key, required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (int i = 0; i < data.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[i % colors.length], borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text(data[i].name, style: const TextStyle(fontSize: 12)),
            ],
          ),
      ],
    );
  }
}

class LegendProductValue extends StatelessWidget {
  final List<ProductValue> data;
  final List<Color> colors;
  const LegendProductValue({super.key, required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (int i = 0; i < data.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[i % colors.length], borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text(data[i].name, style: const TextStyle(fontSize: 12)),
            ],
          ),
      ],
    );
  }
}

class LegendCategoryValue extends StatelessWidget {
  final List<CategoryValue> data;
  final List<Color> colors;
  const LegendCategoryValue({super.key, required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (int i = 0; i < data.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[i % colors.length], borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text(data[i].name, style: const TextStyle(fontSize: 12)),
            ],
          ),
      ],
    );
  }
}

class LegendPaymentValue extends StatelessWidget {
  final List<PaymentValue> data;
  final List<Color> colors;
  final NumberFormat currency;
  const LegendPaymentValue({super.key, required this.data, required this.colors, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        for (int i = 0; i < data.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('${data[i].name}: ${currency.format(data[i].value)}', style: const TextStyle(fontSize: 10)),
            ],
          ),
      ],
    );
  }
}
