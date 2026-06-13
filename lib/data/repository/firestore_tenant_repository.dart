import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../models/tenant_model.dart';
import '../models/today_alert_model.dart';


class FirestoreTenantRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreTenantRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(user.uid).collection('tenants');
  }

  /// CREATE — Firestore auto-generates a stable random Document ID (Option A)
  Future<String> addTenant(TenantModel tenant) async {
    debugPrint('[FirestoreTenantRepository] addTenant called with: ${tenant.fullName}');
    final collection = _getCollection();
    final docRef = collection.doc();
    final now = DateTime.now();

    final batch = _firestore.batch();

    batch.set(docRef, {
      ...tenant.toMap(),
      'id': docRef.id,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    // Update apartment status
    if (tenant.apartmentId != null) {
      final aptRef = _firestore.collection('users').doc(_auth.currentUser!.uid).collection('apartments').doc(tenant.apartmentId!);
      batch.update(aptRef, {
        'tenantId': docRef.id,
        'isRented': true,
      });
      debugPrint('[FirestoreTenantRepository] Added apartment ${tenant.apartmentId} update to batch');
    }

    await batch.commit();
    debugPrint('[FirestoreTenantRepository] Tenant added successfully: ${docRef.id} (Batch committed)');
    return docRef.id;
  }

  /// UPDATE — always via stable Firestore ID
  Future<void> updateTenant(TenantModel tenant) async {
    if (tenant.id == null) throw Exception('Cannot update: tenant.id is null');
    debugPrint('[FirestoreTenantRepository] updateTenant called for id: ${tenant.id}');
    
    final batch = _firestore.batch();
    final tenantRef = _getCollection().doc(tenant.id);

    // Check if apartment changed
    final oldTenant = await getTenantById(tenant.id!);
    if (oldTenant != null && oldTenant.apartmentId != tenant.apartmentId) {
      debugPrint('[FirestoreTenantRepository] Apartment changed from ${oldTenant.apartmentId} to ${tenant.apartmentId}');
      // Clear old apartment
      if (oldTenant.apartmentId != null) {
        final oldAptRef = _firestore.collection('users').doc(_auth.currentUser!.uid).collection('apartments').doc(oldTenant.apartmentId!);
        batch.update(oldAptRef, {
          'tenantId': null,
          'isRented': false,
        });
        debugPrint('[FirestoreTenantRepository] Added old apartment ${oldTenant.apartmentId} clear to batch');
      }
    }

    batch.update(tenantRef, {
      ...tenant.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Update new apartment status
    if (tenant.apartmentId != null) {
      final aptRef = _firestore.collection('users').doc(_auth.currentUser!.uid).collection('apartments').doc(tenant.apartmentId!);
      batch.update(aptRef, {
        'tenantId': tenant.id,
        'isRented': true,
      });
      debugPrint('[FirestoreTenantRepository] Added new apartment ${tenant.apartmentId} update to batch');
    }

    await batch.commit();
    debugPrint('[FirestoreTenantRepository] Tenant updated successfully: ${tenant.id} (Batch committed)');
  }

  /// DELETE — via stable Firestore ID
  Future<void> deleteTenant(String id) async {
    debugPrint('[FirestoreTenantRepository] deleteTenant called for id: $id');
    final tenant = await getTenantById(id);
    final batch = _firestore.batch();
    
    if (tenant != null && tenant.apartmentId != null) {
      debugPrint('[FirestoreTenantRepository] Clearing apartment ${tenant.apartmentId} for deleted tenant');
      final aptRef = _firestore.collection('users').doc(_auth.currentUser!.uid).collection('apartments').doc(tenant.apartmentId!);
      batch.update(aptRef, {
        'tenantId': null,
        'isRented': false,
      });
      debugPrint('[FirestoreTenantRepository] Added apartment ${tenant.apartmentId} clear to batch');
    }

    final tenantRef = _getCollection().doc(id);
    batch.delete(tenantRef);
    
    await batch.commit();
    debugPrint('[FirestoreTenantRepository] Tenant deleted successfully: $id (Batch committed)');
  }

  /// READ ALL — docId injected via fromMap(docId: doc.id)
  Future<List<TenantModel>> getAllTenants() async {
    debugPrint('[FirestoreTenantRepository] getAllTenants called');
    final collection = _getCollection();
    final snapshot = await collection.get(const GetOptions(source: Source.serverAndCache));
    debugPrint('[FirestoreTenantRepository] Fetched ${snapshot.docs.length} tenants');
    return snapshot.docs
        .map((doc) => TenantModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  /// GET BY ID
  Future<TenantModel?> getTenantById(String id) async {
    final collection = _getCollection();
    final doc = await collection.doc(id).get(const GetOptions(source: Source.serverAndCache));
    if (doc.exists && doc.data() != null) {
      return TenantModel.fromMap(doc.data()!, docId: doc.id);
    }
    return null;
  }

  /// SEARCH — local filter
  Future<List<TenantModel>> searchTenants(String query) async {
    final all = await getAllTenants();
    final q = query.toLowerCase();
    return all.where((t) =>
        t.fullName.toLowerCase().contains(q) ||
        t.phoneNumber.contains(q) ||
        t.apartmentNumber.contains(q)).toList();
  }

  /// TENANTS WITH ENDING CONTRACTS (within a date range)
  Future<List<TenantModel>> getTenantsWithEndingContracts(DateTime now, DateTime inFuture) async {
    final all = await getAllTenants();
    return all.where((t) =>
        t.contractEndDate.isAfter(now) &&
        t.contractEndDate.isBefore(inFuture)).toList();
  }

  /// TENANTS WITH LATE PAYMENTS
  Future<List<TenantModel>> getTenantsWithLatePayments(String currentMonth) async {
    final all = await getAllTenants();
    return all.where((t) => t.isPaymentReminderEnabled).toList();
  }

  /// GET TODAY ALERTS
  Future<List<TodayAlert>> getTodayAlerts() async {
    final now = DateTime.now();
    final in30Days = now.add(const Duration(days: 30));
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    // Debug 1: Print total tenants in system first
    final all = await getAllTenants();
    debugPrint('=== ALERT AUDIT: TOTAL TENANTS IN SYSTEM ===');
    debugPrint('Count: ${all.length}');
    for (var t in all) {
      debugPrint('Tenant ID: ${t.id} | Name: ${t.fullName} | Apt: ${t.apartmentNumber} | EndDate: ${t.contractEndDate}');
    }

    final endingContracts = await getTenantsWithEndingContracts(now, in30Days);
    final latePayments = await getTenantsWithLatePayments(currentMonth);

    debugPrint('=== ALERT AUDIT: TENANTS TRIGGERING ALERTS ===');
    debugPrint('Ending Contracts Count: ${endingContracts.length}');
    for (var t in endingContracts) {
      debugPrint('Triggered by ID: ${t.id} | Name: ${t.fullName} | Apt: ${t.apartmentNumber}');
    }
    
    debugPrint('Late Payments Count: ${latePayments.length}');
    for (var t in latePayments) {
      debugPrint('Triggered by ID: ${t.id} | Name: ${t.fullName} | Apt: ${t.apartmentNumber}');
    }

    final generatedAlerts = [
      ...endingContracts.map((t) => TodayAlert(
        title: 'عقد ينتهي قريباً',
        apartmentNumber: t.apartmentNumber,
        tenantName: t.fullName,
        isContractAlert: true,
      )),
      ...latePayments.map((t) => TodayAlert(
        title: 'دفعة متأخرة',
        apartmentNumber: t.apartmentNumber,
        tenantName: t.fullName,
        isContractAlert: false,
      )),
    ];
    
    debugPrint('=== ALERT AUDIT: FINAL GENERATED ALERTS ===');
    for (var a in generatedAlerts) {
      debugPrint('Alert: ${a.title} - ${a.apartmentNumber} (Tenant: ${a.tenantName})');
    }

    return generatedAlerts;
  }
}
