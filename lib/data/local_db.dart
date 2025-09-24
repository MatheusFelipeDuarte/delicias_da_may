import 'dart:async';

import 'package:delicias_da_may/models/client.dart';
import 'package:delicias_da_may/models/expense.dart';
import 'package:delicias_da_may/models/order.dart';
import 'package:delicias_da_may/models/product.dart';
import 'package:delicias_da_may/core/enums.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class LocalDb {
  static final LocalDb instance = LocalDb._();
  LocalDb._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'delicias_da_may.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(Client.createTable);
        await db.execute(Product.createTable);
        await db.execute(Order.createTable);
        await db.execute(Expense.createTable);
        await _seed(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add quantidade column to pedidos if missing
          try {
            await db.execute('ALTER TABLE ${Order.table} ADD COLUMN quantidade INTEGER NOT NULL DEFAULT 1');
          } catch (_) {
            // ignore if column already exists
          }
        }
      },
    );
  }

  Future<void> _seed(Database db) async {
    // optional: seed some products and a client for demo/testing
    final hasProducts = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Product.table}'),
        ) ??
        0;
    if (hasProducts == 0) {
      await db.insert(Product.table, const Product(nome: 'Bolo de pote').toMap());
      await db.insert(Product.table, const Product(nome: 'Brigadeiro').toMap());
      await db.insert(Product.table, const Product(nome: 'Torta').toMap());
    }

    final hasClients = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Client.table}'),
        ) ??
        0;
    if (hasClients == 0) {
      await db.insert(
        Client.table,
        const Client(
          nome: 'Cliente Exemplo',
          endereco: 'Rua das Flores, 123',
          qtdSelos: 3,
          phone: '11999999999',
        ).toMap(),
      );
    }

    final hasOrders = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Order.table}'),
        ) ??
        0;
    if (hasOrders == 0) {
      await db.insert(
        Order.table,
        Order(
          produtoId: 1,
          clienteId: 1,
          valor: 25.00,
          pagamento: PaymentMethod.pix,
          time: DateTime.now(),
        ).toMap(),
      );
    }

    final hasExpenses = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Expense.table}'),
        ) ??
        0;
    if (hasExpenses == 0) {
      await db.insert(
        Expense.table,
        Expense(
          categoria: ExpenseCategory.embalagens,
          valor: 8.5,
          pagamento: PaymentMethod.credito,
          time: DateTime.now(),
        ).toMap(),
      );
    }
  }

  // Export all tables to a JSON string
  Future<String> exportJson() async {
    final db = await database;
    final clients = await db.query(Client.table);
    final products = await db.query(Product.table);
    final orders = await db.query(Order.table);
    final expenses = await db.query(Expense.table);
    final data = {
      'version': 2,
      'clients': clients,
      'products': products,
      'orders': orders,
      'expenses': expenses,
    };
    return jsonEncode(data);
  }

  // Import JSON and replace current DB content
  Future<void> importJson(String json) async {
    final db = await database;
    final data = jsonDecode(json) as Map<String, dynamic>;
    final batch = db.batch();
    // Clear existing
    batch.delete(Order.table);
    batch.delete(Expense.table);
    batch.delete(Client.table);
    batch.delete(Product.table);
    // Insert new
    List clients = (data['clients'] as List?) ?? [];
    for (final c in clients) {
      batch.insert(Client.table, Map<String, Object?>.from(c as Map));
    }
    List products = (data['products'] as List?) ?? [];
    for (final p in products) {
      batch.insert(Product.table, Map<String, Object?>.from(p as Map));
    }
    List orders = (data['orders'] as List?) ?? [];
    for (final o in orders) {
      batch.insert(Order.table, Map<String, Object?>.from(o as Map));
    }
    List expenses = (data['expenses'] as List?) ?? [];
    for (final e in expenses) {
      batch.insert(Expense.table, Map<String, Object?>.from(e as Map));
    }
    await batch.commit(noResult: true);
  }
}
