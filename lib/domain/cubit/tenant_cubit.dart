import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/tenant_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/today_alert_model.dart';

part 'tenant_state.dart';

class TenantCubit extends Cubit<TenantState> {
  final dynamic tenantRepository;

  TenantCubit(this.tenantRepository) : super(TenantInitial());

  Future<void> loadTenants() async {
    emit(TenantLoading());
    try {
      final tenants = await tenantRepository.getAllTenants();
      emit(TenantLoaded(tenants));
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }
  Future<void> loadTodayAlerts() async {
    emit(TenantLoading());
    try {
      final alerts = await tenantRepository.getTodayAlerts();
      
      // DEBUG: Read counts directly for investigation
      try {
        final allTenants = await tenantRepository.getAllTenants();
        // Since TenantCubit doesn't have contractRepo, we will just print what we can
        // To count contracts we need to import Firestore
        final snapshot = await FirebaseFirestore.instance.collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('contracts').get(const GetOptions(source: Source.serverAndCache));
        debugPrint('--- TODAY ALERTS AUDIT ---');
        debugPrint('Total Tenants in Firestore: ${allTenants.length}');
        debugPrint('Total Contracts in Firestore: ${snapshot.docs.length}');
        debugPrint('Total Alerts Generated: ${alerts.length}');
        debugPrint('Alerts: ${alerts.map((a) => "${a.title} - ${a.tenantName}").toList()}');
      } catch (debugError) {
        debugPrint('Debug error: $debugError');
      }

      if (alerts.isEmpty) {
        emit(TodayAlertsEmpty());
      } else {
        emit(TodayAlertsLoaded(alerts));
      }
    } catch (e) {
      debugPrint('Error in loadTodayAlerts: $e');
      emit(TenantError('فشل تحميل التنبيهات: ${e.toString()}'));
    }
  }
  Future<void> addTenant(TenantModel tenant) async {
    try {
      await tenantRepository.addTenant(tenant);
      emit(TenantAdded());
      await loadTenants();
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> updateTenant(TenantModel tenant) async {
    try {
      await tenantRepository.updateTenant(tenant);
      emit(TenantUpdated());
      await loadTenants();
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> deleteTenant(String id) async {
    try {
      await tenantRepository.deleteTenant(id);
      emit(TenantDeleted());
      await loadTenants();
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> searchTenants(String query) async {
    emit(TenantLoading());
    try {
      final tenants = await tenantRepository.searchTenants(query);
      emit(TenantLoaded(tenants));
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> loadLatePaymentsTenants(String currentMonth) async {
    emit(TenantLoading());
    try {
      final tenants = await tenantRepository.getTenantsWithLatePayments(currentMonth);
      emit(TenantLoaded(tenants));
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }
  Future<TenantModel?> getTenantById(String tenantId) async {
    try {
      return await tenantRepository.getTenantById(tenantId);
    } catch (e) {
      debugPrint('Error getting tenant by ID: $e');
      return null;
    }
  }

  Future<void> loadEndingContractsTenants(DateTime startDate, DateTime endDate) async {
    emit(TenantLoading());
    try {
      final tenants = await tenantRepository.getTenantsWithEndingContracts(startDate, endDate);
      emit(TenantLoaded(tenants));
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }
}

