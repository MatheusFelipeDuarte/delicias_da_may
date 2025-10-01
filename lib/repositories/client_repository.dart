import 'package:delicias_da_may/data/firestore_db.dart';
import 'package:delicias_da_may/data/firestore_counters.dart';
import 'package:delicias_da_may/models/client.dart';

class ClientRepository {
  final _col = FirestoreDb.clientsCol();

  // Firestore will use String document IDs. We'll keep the method signature
  // but treat the integer as a string ID for compatibility with existing code paths.
  Future<Client?> getById(int id) async {
    final doc = await _col.doc(id.toString()).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return Client.fromMap({
      'id': id,
      'nome': data['nome'],
      'endereco': data['endereco'],
      'qtd_selos': data['qtd_selos'],
      'phone': data['phone'],
    });
  }

  Future<List<Client>> listAll() async {
    final snap = await _col.orderBy('nome').get();
    return snap.docs.map((d) {
      final data = d.data();
      return Client.fromMap({
        'id': int.tryParse(d.id),
        'nome': data['nome'],
        'endereco': data['endereco'],
        'qtd_selos': data['qtd_selos'],
        'phone': data['phone'],
      });
    }).toList();
  }

  Future<int> insert(Client client) async {
    final id = (client.id ?? await FirestoreCounters.next('clients')).toString();
    await _col.doc(id).set({
      'nome': client.nome,
      'endereco': client.endereco,
      'qtd_selos': client.qtdSelos,
      'phone': client.phone,
    });
    return 1;
  }

  Future<int> delete(int id) async {
    await _col.doc(id.toString()).delete();
    return 1;
  }

  Future<int> update(Client client) async {
    final id = client.id?.toString();
    if (id == null) return 0;
    await _col.doc(id).update({
      'nome': client.nome,
      'endereco': client.endereco,
      'qtd_selos': client.qtdSelos,
      'phone': client.phone,
    });
    return 1;
  }
}
