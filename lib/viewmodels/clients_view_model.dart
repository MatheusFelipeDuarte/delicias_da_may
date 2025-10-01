import 'package:delicias_da_may/models/client.dart';
import 'package:delicias_da_may/repositories/client_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:delicias_da_may/data/data_cache.dart';
import 'package:delicias_da_may/repositories/product_repository.dart';
import 'package:delicias_da_may/repositories/order_repository.dart';
import 'package:delicias_da_may/repositories/expense_repository.dart';

class ClientsViewModel extends ChangeNotifier {
  final ClientRepository repo;
  ClientsViewModel(this.repo);

  List<Client> _all = [];
  String _query = '';

  List<Client> get filtered => _all
    .where((c) => _query.isEmpty ||
      c.nome.toLowerCase().contains(_query) ||
      c.endereco.toLowerCase().contains(_query) ||
      c.phone.toLowerCase().contains(_query))
    .toList();

  Future<void> init() async {
    _all = await repo.listAll();
    await DataCache.instance.ensureLoaded(
      clientsRepo: repo,
      productsRepo: ProductRepository(),
      ordersRepo: OrderRepository(),
      expensesRepo: ExpenseRepository(),
    );
    _all = DataCache.instance.clients;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q.toLowerCase();
    notifyListeners();
  }

  Future<void> refresh() async {
    _all = await repo.listAll();
    await DataCache.instance.refreshAll(
      clientsRepo: repo,
      productsRepo: ProductRepository(),
      ordersRepo: OrderRepository(),
      expensesRepo: ExpenseRepository(),
    );
    _all = DataCache.instance.clients;
    notifyListeners();
  }

  Future<void> addClient({
    required String nome,
    required String endereco,
    required String phone,
    int qtdSelos = 0,
  }) async {
    await repo.insert(Client(nome: nome, endereco: endereco, qtdSelos: qtdSelos, phone: phone));
    await DataCache.instance.refreshAll(
      clientsRepo: repo,
      productsRepo: ProductRepository(),
      ordersRepo: OrderRepository(),
      expensesRepo: ExpenseRepository(),
    );
    await refresh();
  }
}
