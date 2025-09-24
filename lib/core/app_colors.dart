import 'package:flutter/material.dart';

class AppColors {
  static const Color rosaClaro = Color(0xFFFADADD);
  static const Color rosa = Color(0xFFFFC4CA);
  static const Color dourado = Color(0xFFD4AF37);
  static const Color marromChocolate = Color(0xFF6B3E26);
  static const Color begeClaro = Color(0xFFFFF4E4);
  static const Color branco = Color(0xFFFFFFFF);
  static const Color cinzaClaro = Color(0xFFF5F5F5);

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: dourado,
        primary: dourado,
        secondary: rosa,
        surface: begeClaro,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: rosaClaro,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: dourado,
        foregroundColor: branco,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: begeClaro,
        foregroundColor: marromChocolate,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: branco,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: marromChocolate,
        displayColor: marromChocolate,
      ),
    );
  }
}
