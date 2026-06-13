import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class FirestoreExpenseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreExpenseRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(user.uid).collection('expenses');
  }

  /// CREATE
  Future<String> addExpense(ExpenseModel expense) async {
    final collection = _getCollection();
    final docRef = collection.doc();
    final now = DateTime.now();

    await docRef.set({
      ...expense.toMap(),
      'id': docRef.id,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    return docRef.id;
  }

  /// UPDATE
  Future<void> updateExpense(ExpenseModel expense) async {
    if (expense.id == null) throw Exception('Cannot update: expense.id is null');
    final collection = _getCollection();
    await collection.doc(expense.id).update({
      ...expense.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// DELETE
  Future<void> deleteExpense(String id) async {
    final collection = _getCollection();
    await collection.doc(id).delete();
  }

  /// READ ALL
  Future<List<ExpenseModel>> getAllExpenses() async {
    final collection = _getCollection();
    final snapshot = await collection.get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  /// GET BY ID
  Future<ExpenseModel?> getExpenseById(String id) async {
    final collection = _getCollection();
    final doc = await collection.doc(id).get(const GetOptions(source: Source.serverAndCache));
    if (doc.exists && doc.data() != null) {
      return ExpenseModel.fromMap(doc.data()!, docId: doc.id);
    }
    return null;
  }

  /// GET TOTAL EXPENSES
  Future<double> getTotalExpenses() async {
    final all = await getAllExpenses();
    return all.fold<double>(0.0, (acc, exp) => acc + exp.amount);
  }

  /// GET TOTAL EXPENSES BY MONTH
  Future<Map<String, double>> getTotalExpensesByMonth() async {
    final all = await getAllExpenses();
    final Map<String, double> map = {};
    for (var e in all) {
      // Create a 'yyyy-MM' string format from the date
      final month = "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}";
      map[month] = (map[month] ?? 0.0) + e.amount;
    }
    return map;
  }

  /// GET EXPENSES BY TYPE
  Future<Map<String, double>> getExpensesByType(DateTime startDate, DateTime endDate) async {
    final all = await getAllExpenses();
    final Map<String, double> map = {};
    for (var e in all) {
      if (e.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
          e.date.isBefore(endDate.add(const Duration(days: 1)))) {
        map[e.type] = (map[e.type] ?? 0.0) + e.amount;
      }
    }
    return map;
  }
}
