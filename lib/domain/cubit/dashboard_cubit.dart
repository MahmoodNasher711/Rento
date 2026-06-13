// ignore_for_file: prefer_initializing_formals
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rento/data/repository/firestore_expense_repository.dart';
import 'package:rento/data/repository/firestore_payment_repository.dart';
import 'package:rento/data/repository/firestore_tenant_repository.dart';
import 'package:rento/data/repository/firestore_apartment_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final FirestoreTenantRepository _tenantRepository;
  final FirestorePaymentRepository _paymentRepository;
  final FirestoreExpenseRepository _expenseRepository;
  final FirestoreApartmentRepository _apartmentRepository;

  DashboardCubit({
    required FirestoreTenantRepository tenantRepository,
    required FirestorePaymentRepository paymentRepository,
    required FirestoreExpenseRepository expenseRepository,
    required FirestoreApartmentRepository apartmentRepository,
  })  : _tenantRepository = tenantRepository,
        _paymentRepository = paymentRepository,
        _expenseRepository = expenseRepository,
        _apartmentRepository = apartmentRepository,
        super(DashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    try {
      final currentMonth = _getCurrentMonth();
      final now = DateTime.now();
      final in30Days = now.add(const Duration(days: 30));

      // Execute all repository calls in parallel
      final results = await Future.wait<dynamic>([
        _apartmentRepository.getRentedApartments(),
        _apartmentRepository.getVacantApartments(),
        _paymentRepository.getTotalRents(),
        _expenseRepository.getTotalExpenses(),
        _tenantRepository.getTenantsWithLatePayments(currentMonth) as Future<dynamic>,
        _tenantRepository.getTenantsWithEndingContracts(now, in30Days) as Future<dynamic>,
      ], eagerError: true);

      emit(DashboardLoaded(
        rentedApartmentsCount: (results[0] as List).length,
        vacantApartmentsCount: (results[1] as List).length,
        totalRents: results[2] as double,
        totalExpenses: results[3] as double,
        latePaymentsCount: (results[4] as List).length,
        endingContractsCount: (results[5] as List).length,
      ));
    } catch (e) {
      emit(DashboardError(_getErrorMessage(e)));
    }
  }

  String _getCurrentMonth() {
    return DateFormat('yyyy-MM').format(DateTime.now());
  }

  String _getErrorMessage(Object e) {
    return 'Failed to load dashboard data: ${e.toString()}';
  }
}
