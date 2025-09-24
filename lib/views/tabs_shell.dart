import 'package:delicias_da_may/core/app_colors.dart';
import 'package:delicias_da_may/views/calendar_screen.dart';
import 'package:delicias_da_may/views/clients_screen.dart';
import 'package:delicias_da_may/views/products_screen.dart';
import 'package:delicias_da_may/views/finance_screen.dart';
import 'package:flutter/material.dart';

class TabsShell extends StatefulWidget {
  const TabsShell({super.key});

  @override
  State<TabsShell> createState() => _TabsShellState();
}

class _TabsShellState extends State<TabsShell> {
  int _index = 0;

  final _pages = const [CalendarScreen(), ClientsScreen(), ProductsScreen(), FinanceScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.begeClaro,
        selectedItemColor: AppColors.marromChocolate,
        unselectedItemColor: AppColors.marromChocolate.withValues(alpha: 0.7),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendário'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Clientes'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Produtos'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Financeiro'),
        ],
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
