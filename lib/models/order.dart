import 'package:delicias_da_may/core/enums.dart';

class Order {
  final int? id;
  final int produtoId;
  final int clienteId;
  final double valor;
  final int quantidade;
  final PaymentMethod pagamento;
  final DateTime time;

  const Order({
    this.id,
    required this.produtoId,
    required this.clienteId,
    required this.valor,
    this.quantidade = 1,
    required this.pagamento,
    required this.time,
  });

  static const table = 'pedidos';
  static const createTable = '''
  CREATE TABLE IF NOT EXISTS $table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    produto_id INTEGER NOT NULL,
    cliente_id INTEGER NOT NULL,
    valor REAL NOT NULL,
    quantidade INTEGER NOT NULL DEFAULT 1,
    pagamento TEXT NOT NULL,
    time INTEGER NOT NULL,
    FOREIGN KEY(produto_id) REFERENCES produtos(id),
    FOREIGN KEY(cliente_id) REFERENCES clientes(id)
  );
  ''';

  Map<String, Object?> toMap() => {
        'id': id,
        'produto_id': produtoId,
        'cliente_id': clienteId,
        'valor': valor,
    'quantidade': quantidade,
        'pagamento': pagamento.label,
        'time': time.millisecondsSinceEpoch,
      };

  factory Order.fromMap(Map<String, Object?> map) => Order(
        id: map['id'] as int?,
        produtoId: (map['produto_id'] as num).toInt(),
        clienteId: (map['cliente_id'] as num).toInt(),
        valor: (map['valor'] as num).toDouble(),
        quantidade: (map['quantidade'] as num?)?.toInt() ?? 1,
        pagamento: PaymentMethodX.parse(map['pagamento'] as String),
        time: DateTime.fromMillisecondsSinceEpoch((map['time'] as num).toInt()),
      );
}
