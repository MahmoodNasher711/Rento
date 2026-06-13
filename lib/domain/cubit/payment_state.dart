part of 'payment_cubit.dart';

@immutable

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentModel> payments;

  PaymentLoaded(this.payments);
}
class RecentPaymentsLoaded extends PaymentState {
  final List<PaymentModel> payments;

  RecentPaymentsLoaded(this.payments);
}
class PaymentAdded extends PaymentState {}

class PaymentUpdated extends PaymentState {}

class PaymentDeleted extends PaymentState {}

class PaymentError extends PaymentState {
  final String message;

  PaymentError(this.message);
}
