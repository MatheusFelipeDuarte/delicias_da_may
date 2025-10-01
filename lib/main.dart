import 'package:delicias_da_may/core/app_colors.dart';
import 'package:delicias_da_may/repositories/client_repository.dart';
import 'package:delicias_da_may/repositories/expense_repository.dart';
import 'package:delicias_da_may/repositories/order_repository.dart';
import 'package:delicias_da_may/repositories/product_repository.dart';
import 'package:delicias_da_may/viewmodels/calendar_view_model.dart';
import 'package:delicias_da_may/viewmodels/clients_view_model.dart';
import 'package:delicias_da_may/viewmodels/products_view_model.dart';
import 'package:delicias_da_may/viewmodels/finance_view_model.dart';
import 'package:delicias_da_may/views/tabs_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
// If you generate firebase_options.dart via FlutterFire CLI, you can import it:
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // If using FlutterFire CLI generated options:
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize intl for pt_BR used by TableCalendar
  initializeDateFormatting('pt_BR');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CalendarViewModel(
            orderRepo: OrderRepository(),
            expenseRepo: ExpenseRepository(),
            clientRepo: ClientRepository(),
            productRepo: ProductRepository(),
          )..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClientsViewModel(ClientRepository())..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsViewModel(ProductRepository())..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => FinanceViewModel(
            orderRepository: OrderRepository(),
            expenseRepository: ExpenseRepository(),
            productRepository: ProductRepository(),
          )..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Delícias da May',
        theme: AppColors.theme(),
        home: const TabsShell(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
