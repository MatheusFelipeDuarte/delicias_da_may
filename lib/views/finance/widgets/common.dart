import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

// Shared palette for all finance charts
List<Color> palette() => const [
      Color(0xFFF4C430),
      AppColors.marromChocolate,
      Color(0xFFB5651D),
      Color(0xFFFFE5B4),
      Color(0xFF8B4513),
      Color(0xFFFFA500),
      Color(0xFFCD853F),
    ];

List<Color> buildColors(int n) {
  final base = palette();
  if (n <= base.length) return base.sublist(0, n);
  return List<Color>.generate(n, (i) => base[i % base.length]);
}

String compactCurrency(double v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
  if (v >= 100) return v.toStringAsFixed(0);
  if (v >= 10) return v.toStringAsFixed(1);
  return v.toStringAsFixed(2);
}
