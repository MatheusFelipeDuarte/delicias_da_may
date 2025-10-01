import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDb {
  static final FirebaseFirestore instance = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> clientsCol() => instance.collection('clients');
  static CollectionReference<Map<String, dynamic>> productsCol() => instance.collection('products');
  static CollectionReference<Map<String, dynamic>> ordersCol() => instance.collection('orders');
  static CollectionReference<Map<String, dynamic>> expensesCol() => instance.collection('expenses');
}
