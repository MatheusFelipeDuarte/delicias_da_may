import 'package:delicias_da_may/models/product.dart';
import 'package:delicias_da_may/repositories/product_repository.dart';
import 'package:flutter/foundation.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductRepository repo;
  ProductsViewModel(this.repo);

  List<Product> _all = [];
  String _query = '';

  List<Product> get filtered => _all
      .where((p) => _query.isEmpty || p.nome.toLowerCase().contains(_query))
      .toList();

  Future<void> init() async {
    _all = await repo.listAll();
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q.toLowerCase();
    notifyListeners();
  }

  Future<void> refresh() async {
    _all = await repo.listAll();
    notifyListeners();
  }

  Future<void> addProduct(String nome) async {
    await repo.insert(Product(nome: nome.trim()));
    await refresh();
  }
}
