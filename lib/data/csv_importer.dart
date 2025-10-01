import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:delicias_da_may/core/enums.dart';
import 'package:delicias_da_may/models/client.dart';
import 'package:delicias_da_may/models/product.dart';
import 'package:delicias_da_may/models/order.dart';
import 'package:delicias_da_may/models/expense.dart';
import 'package:delicias_da_may/repositories/client_repository.dart';
import 'package:delicias_da_may/repositories/product_repository.dart';
import 'package:delicias_da_may/repositories/order_repository.dart';
import 'package:delicias_da_may/repositories/expense_repository.dart';
import 'package:intl/intl.dart';

class CsvImporter {
  final ClientRepository clients;
  final ProductRepository products;
  final OrderRepository orders;
  final ExpenseRepository expenses;
  CsvImporter({required this.clients, required this.products, required this.orders, required this.expenses});

  Future<void> importFile(File file) async {
    final raw = await file.readAsBytes();
    // Try to decode as UTF-8, fallback to Latin1 if needed
    String content;
    try {
      content = utf8.decode(raw);
    } catch (_) {
      content = latin1.decode(raw);
    }

    final rows = const CsvToListConverter(fieldDelimiter: ',', eol: '\n', shouldParseNumbers: false).convert(content);
    if (rows.isEmpty) return;
    final header = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();

    int idxOf(String name) {
      final i = header.indexOf(name.toLowerCase());
      if (i < 0) throw Exception('Coluna "$name" não encontrada no CSV');
      return i;
    }

    final iDate = idxOf('date');
    final iMode = idxOf('mode');
    final iCategoria = idxOf('categoria');
    final iProduto = idxOf('produto');
    final iCliente = idxOf('cliente');
    final iEndereco = idxOf('endereço');
    final iTelefone = idxOf('telefone');
    final iQuantidade = idxOf('quantidade');
    final iValor = idxOf('valor');
    final iPagamento = idxOf('pagamento');

    // Caches to reduce reads: name -> id
    final Map<String, int> productIdByName = {};
    final Map<String, int> clientIdByKey = {}; // key = "$nome|$endereco|$telefone"

    // Preload existing products and clients to map duplicates by name
    final existingProducts = await products.listAll();
    for (final p in existingProducts) {
      productIdByName[p.nome.trim().toLowerCase()] = p.id ?? 0;
    }
    final existingClients = await clients.listAll();
    for (final c in existingClients) {
      clientIdByKey[_clientKey(c.nome, c.endereco, c.phone)] = c.id ?? 0;
    }

    // Helpers
    final dateParser = DateFormat('dd/MM/yyyy');
    PaymentMethod parsePayment(String s) => PaymentMethodX.parse(s);
    ExpenseCategory parseCategory(String s) => ExpenseCategoryX.parse(s);
    double? parseValor(String s) {
      if (s.isEmpty) return null;
      s = s.replaceAll(RegExp(r'[^0-9,.-]'), '').replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(s);
    }

    for (int r = 1; r < rows.length; r++) {
      final row = rows[r];
      if (row.isEmpty) continue;
      String getStr(int i) => (i < row.length ? (row[i]?.toString() ?? '') : '').trim();

      final dateStr = getStr(iDate);
      final mode = getStr(iMode).toLowerCase(); // 'venda' ou 'gasto'
      final categoria = getStr(iCategoria);
      final produtoName = getStr(iProduto);
      final clienteName = getStr(iCliente);
      final endereco = getStr(iEndereco);
      final telefone = getStr(iTelefone);
      final quantidadeStr = getStr(iQuantidade);
      final valorStr = getStr(iValor);
      final pagamentoStr = getStr(iPagamento);

      if (dateStr.isEmpty || mode.isEmpty) continue;
      DateTime date;
      try {
        date = dateParser.parse(dateStr);
      } catch (_) {
        // tenta outro formato (por segurança)
        try {
          date = DateFormat('dd/MM/yy').parse(dateStr);
        } catch (_) {
          continue; // pula linha inválida
        }
      }

      final pagamento = parsePayment(pagamentoStr);
      final qtd = int.tryParse(quantidadeStr.isEmpty ? '1' : quantidadeStr) ?? 1;
      final valor = parseValor(valorStr) ?? 0.0;

      if (mode == 'gasto') {
        final cat = parseCategory(categoria);
        await expenses.insert(Expense(
          categoria: cat,
          valor: valor,
          pagamento: pagamento,
          time: date,
        ));
        continue;
      }

      // venda
      if (produtoName.isEmpty || clienteName.isEmpty) {
        // dados insuficientes para pedido
        continue;
      }

      // produto (de-duplicado por nome case-insensitive)
      final prodKey = produtoName.trim().toLowerCase();
      int? produtoId = productIdByName[prodKey];
      if (produtoId == null || produtoId == 0) {
        // cria
        await products.insert(Product(nome: produtoName.trim()));
        final refreshed = await products.listAll();
        final created = refreshed.firstWhere((p) => p.nome.toLowerCase() == prodKey, orElse: () => const Product(id: null, nome: ''));
        if (created.id != null) {
          produtoId = created.id;
          productIdByName[prodKey] = produtoId!;
        }
      }

      // cliente (de-duplicado por nome+endereco+telefone)
      final cKey = _clientKey(clienteName, endereco, telefone);
      int? clienteId = clientIdByKey[cKey];
      if (clienteId == null || clienteId == 0) {
        await clients.insert(Client(nome: clienteName.trim(), endereco: endereco.trim(), qtdSelos: 0, phone: telefone.trim()))
            .then((_) async {
          final list = await clients.listAll();
          final created = list.firstWhere(
            (c) => _clientKey(c.nome, c.endereco, c.phone) == cKey,
            orElse: () => const Client(id: null, nome: '', endereco: '', qtdSelos: 0, phone: ''),
          );
          if (created.id != null) {
            clienteId = created.id;
            clientIdByKey[cKey] = clienteId!;
          }
        });
      }

      if (produtoId == null || clienteId == null) continue;

      await orders.insert(Order(
        produtoId: produtoId,
        clienteId: clienteId!,
        valor: valor,
        quantidade: qtd,
        pagamento: pagamento,
        time: date,
      ));
    }
  }

  static String _clientKey(String nome, String endereco, String phone) {
    return '${nome.trim().toLowerCase()}|${endereco.trim().toLowerCase()}|${phone.trim()}';
  }
}
