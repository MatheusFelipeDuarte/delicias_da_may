class Client {
  final int? id;
  final String nome;
  final String endereco;
  final int qtdSelos; // 1..10
  final String phone;

  const Client({
    this.id,
    required this.nome,
    required this.endereco,
    required this.qtdSelos,
    required this.phone,
  });

  Client copyWith({int? id, String? nome, String? endereco, int? qtdSelos, String? phone}) =>
      Client(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        endereco: endereco ?? this.endereco,
        qtdSelos: qtdSelos ?? this.qtdSelos,
        phone: phone ?? this.phone,
      );

  static const table = 'clientes';
  static const createTable = '''
  CREATE TABLE IF NOT EXISTS $table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    endereco TEXT NOT NULL,
    qtd_selos INTEGER NOT NULL,
    phone TEXT NOT NULL
  );
  ''';

  Map<String, Object?> toMap() => {
        'id': id,
        'nome': nome,
        'endereco': endereco,
        'qtd_selos': qtdSelos,
        'phone': phone,
      };

  factory Client.fromMap(Map<String, Object?> map) => Client(
        id: map['id'] as int?,
        nome: map['nome'] as String,
        endereco: map['endereco'] as String,
        qtdSelos: (map['qtd_selos'] as num).toInt(),
        phone: map['phone'] as String,
      );
}
