import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/apartment_model.dart';

class FirestoreApartmentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreApartmentRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(user.uid).collection('apartments');
  }

  /// CREATE — Firestore auto-generates a stable random Document ID (Option A)
  Future<void> addApartment(ApartmentModel apartment) async {
    final collection = _getCollection();
    final docRef = collection.doc();
    final modelWithId = apartment.copyWith(id: docRef.id);
    await docRef.set(modelWithId.toMap());
  }

  /// UPDATE — always by stable Firestore ID, not by apartment number
  Future<void> updateApartment(ApartmentModel apartment) async {
    if (apartment.id == null) throw Exception('Cannot update: apartment.id is null');
    final collection = _getCollection();
    await collection.doc(apartment.id).update(apartment.toMap());
  }

  /// DELETE — by stable Firestore ID
  Future<void> deleteApartment(String id) async {
    final collection = _getCollection();
    await collection.doc(id).delete();
  }

  /// READ ALL — docId injected via fromMap(docId: doc.id)
  Future<List<ApartmentModel>> getAllApartments() async {
    final collection = _getCollection();
    final snapshot = await collection.get(const GetOptions(source: Source.serverAndCache));
    return snapshot.docs
        .map((doc) => ApartmentModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  /// GET BY ID
  Future<ApartmentModel?> getApartmentById(String id) async {
    final collection = _getCollection();
    final doc = await collection.doc(id).get(const GetOptions(source: Source.serverAndCache));
    if (doc.exists && doc.data() != null) {
      return ApartmentModel.fromMap(doc.data()!, docId: doc.id);
    }
    return null;
  }

  /// READ VACANT — filter locally to avoid isRented 0/false duality
  Future<List<ApartmentModel>> getVacantApartments() async {
    final all = await getAllApartments();
    return all.where((a) => !a.isRented).toList();
  }

  /// READ RENTED
  Future<List<ApartmentModel>> getRentedApartments() async {
    final all = await getAllApartments();
    return all.where((a) => a.isRented).toList();
  }
}
