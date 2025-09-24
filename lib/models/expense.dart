import 'package:delicias_da_may/core/enums.dart';

class Expense {
  final int? id;
  final ExpenseCategory categoria;
  final double valor;
  final PaymentMethod pagamento;
  final DateTime time;

  const Expense({
    this.id,
    required this.categoria,
    required this.valor,
    required this.pagamento,
    required this.time,
  });

  static const table = 'gastos';
  static const createTable = '''
  CREATE TABLE IF NOT EXISTS $table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    categoria TEXT NOT NULL,
    valor REAL NOT NULL,
    pagamento TEXT NOT NULL,
    time INTEGER NOT NULL
  );
  ''';

  Map<String, Object?> toMap() => {
        'id': id,
        'categoria': categoria.label,
        'valor': valor,
        'pagamento': pagamento.label,
        'time': time.millisecondsSinceEpoch,
      };

  factory Expense.fromMap(Map<String, Object?> map) => Expense(
        id: map['id'] as int?,
        categoria: ExpenseCategoryX.parse(map['categoria'] as String),
        valor: (map['valor'] as num).toDouble(),
        pagamento: PaymentMethodX.parse(map['pagamento'] as String),
        time: DateTime.fromMillisecondsSinceEpoch((map['time'] as num).toInt()),
      );
}
