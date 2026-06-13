import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_model.dart';

class FirestorePaymentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestorePaymentRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(user.uid).collection('payments');
  }

  /// CREATE
  Future<String> addPayment(PaymentModel payment) async {
    final collection = _getCollection();
    final docRef = collection.doc();
    final now = DateTime.now();

    await docRef.set({
      ...payment.toMap(),
      'id': docRef.id,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    return docRef.id;
  }

  /// UPDATE
  Future<void> updatePayment(PaymentModel payment) async {
    if (payment.id == null) throw Exception('Cannot update: payment.id is null');
    final collection = _getCollection();
    await collection.doc(payment.id).update({
      ...payment.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// DELETE
  Future<void> deletePayment(String id) async {
    final collection = _getCollection();
    await collection.doc(id).delete();
  }

  /// READ ALL
  Future<List<PaymentModel>> getAllPayments() async {
    final collection = _getCollection();
    final snapshot = await collection.get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs
        .map((doc) => PaymentModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  /// GET BY TENANT ID
  Future<List<PaymentModel>> getPaymentsByTenant(String tenantId) async {
    final collection = _getCollection();
    final snapshot = await collection
        .where('tenantId', isEqualTo: tenantId)
        .get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs
        .map((doc) => PaymentModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  /// GET RECENT
  Future<List<PaymentModel>> getRecentTransactions(int limit) async {
    final collection = _getCollection();
    final snapshot = await collection
        .orderBy('paymentDate', descending: true)
        .limit(limit)
        .get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs
        .map((doc) => PaymentModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  /// GET TOTAL RENTS
  Future<double> getTotalRents() async {
    final all = await getAllPayments();
    return all.fold<double>(0.0, (acc, payment) => acc + payment.amount);
  }

  /// GET TOTAL RENTS BY MONTH
  Future<Map<String, double>> getTotalRentsByMonth() async {
    final all = await getAllPayments();
    final Map<String, double> map = {};
    for (var p in all) {
      map[p.month] = (map[p.month] ?? 0.0) + p.amount;
    }
    return map;
  }
}
