import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/payment_model.dart';
import 'package:rento/data/repository/firestore_payment_repository.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final FirestorePaymentRepository paymentRepository;

  PaymentCubit(this.paymentRepository) : super(PaymentInitial());

  Future<void> loadPayments() async {
    emit(PaymentLoading());
    try {
      final payments = await paymentRepository.getAllPayments();
      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> addPayment(PaymentModel payment) async {
    try {
      await paymentRepository.addPayment(payment);
      emit(PaymentAdded());
      await loadPayments();
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> loadRecentPayments() async {
    emit(PaymentLoading());
    try {
      final payments = await paymentRepository.getRecentTransactions(5);
      emit(RecentPaymentsLoaded(payments));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> updatePayment(PaymentModel payment) async {
    try {
      await paymentRepository.updatePayment(payment);
      emit(PaymentUpdated());
      await loadPayments();
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await paymentRepository.deletePayment(id);
      emit(PaymentDeleted());
      await loadPayments();
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> loadPaymentsByTenant(String tenantId) async {
    emit(PaymentLoading());
    try {
      final payments = await paymentRepository.getPaymentsByTenant(tenantId);
      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<Map<String, double>> getTotalRentsByMonth() async {
    try {
      return await paymentRepository.getTotalRentsByMonth();
    } catch (e) {
      emit(PaymentError(e.toString()));
      return {};
    }
  }

  Future<Object> getTotalRents() async {
    try {
      return await paymentRepository.getTotalRents();
    } catch (e) {
      emit(PaymentError(e.toString()));
      return 0.0;
    }
  }
}
