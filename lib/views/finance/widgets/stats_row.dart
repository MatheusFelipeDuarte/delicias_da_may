import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class StatsRow extends StatelessWidget {
  final String ganhosText;
  final String gastosText;
  final String lucroText;
  const StatsRow({super.key, required this.ganhosText, required this.gastosText, required this.lucroText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatsBlock(
          title: 'Ganhos',
          value: ganhosText,
          background: const Color(0xFFF4C430),
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
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
