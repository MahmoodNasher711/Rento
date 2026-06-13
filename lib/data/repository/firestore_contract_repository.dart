import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contract_model.dart';

class FirestoreContractRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreContractRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(user.uid).collection('contracts');
  }

  /// CREATE
  Future<String> addContract(ContractModel contract) async {
    final collection = _getCollection();
    final docRef = collection.doc();
    final now = DateTime.now();

    await docRef.set({
      ...contract.toMap(),
      'id': docRef.id,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    return docRef.id;
  }

  /// UPDATE
  Future<void> updateContract(ContractModel contract) async {
    if (contract.id == null) throw Exception('Cannot update: contract.id is null');
    final collection = _getCollection();
    await collection.doc(contract.id).update({
      ...contract.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// DELETE
  Future<void> deleteContract(String id) async {
    final collection = _getCollection();
    await collection.doc(id).delete();
  }

  /// READ ALL
  Future<List<ContractModel>> getAllContracts() async {
    final collection = _getCollection();
    final snapshot = await collection.get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs
        .map((doc) => ContractModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  /// GET BY TENANT ID
  Future<List<ContractModel>> getContractsByTenant(String tenantId) async {
    final collection = _getCollection();
    final snapshot = await collection
        .where('tenantId', isEqualTo: tenantId)
        .get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs
        .map((doc) => ContractModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }
}
