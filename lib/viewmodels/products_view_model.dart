import 'package:delicias_da_may/models/product.dart';
import 'package:delicias_da_may/repositories/product_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:delicias_da_may/data/data_cache.dart';
import 'package:delicias_da_may/repositories/order_repository.dart';
import 'package:delicias_da_may/repositories/expense_repository.dart';
import 'package:delicias_da_may/repositories/client_repository.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductRepository repo;
  ProductsViewModel(this.repo);

  List<Product> _all = [];
  String _query = '';

  List<Product> get filtered => _all
      .where((p) => _query.isEmpty || p.nome.toLowerCase().contains(_query))
      .toList();

  Future<void> init() async {
    await DataCache.instance.ensureLoaded(
      clientsRepo: ClientRepository(),
      productsRepo: repo,
      ordersRepo: OrderRepository(),
      expensesRepo: ExpenseRepository(),
    );
    _all = DataCache.instance.products;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q.toLowerCase();
    notifyListeners();
  }

  Future<void> refresh() async {
    await DataCache.instance.refreshAll(
      clientsRepo: ClientRepository(),
      productsRepo: repo,
      ordersRepo: OrderRepository(),
      expensesRepo: ExpenseRepository(),
    );
    _all = DataCache.instance.products;
    notifyListeners();
  }

  Future<void> addProduct(String nome) async {
    await repo.insert(Product(nome: nome.trim()));
    await DataCache.instance.refreshAll(
      clientsRepo: ClientRepository(),
      productsRepo: repo,
      ordersRepo: OrderRepository(),
      expensesRepo: ExpenseRepository(),
    );
    await refresh();
  }
}
