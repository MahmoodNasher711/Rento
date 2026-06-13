part of 'expense_cubit.dart';

@immutable

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;

  ExpenseLoaded(this.expenses);
}

class ExpenseAdded extends ExpenseState {}

class ExpenseUpdated extends ExpenseState {}

class ExpenseDeleted extends ExpenseState {}

class ExpenseError extends ExpenseState {
  final String message;

  ExpenseError(this.message);
}
