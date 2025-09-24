class Product {
  final int? id;
  final String nome;

  const Product({this.id, required this.nome});

  Product copyWith({int? id, String? nome}) => Product(id: id ?? this.id, nome: nome ?? this.nome);

  static const table = 'produtos';
  static const createTable = '''
  CREATE TABLE IF NOT EXISTS $table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL
  );
  ''';

  Map<String, Object?> toMap() => {'id': id, 'nome': nome};

  factory Product.fromMap(Map<String, Object?> map) =>
      Product(id: map['id'] as int?, nome: map['nome'] as String);
}
