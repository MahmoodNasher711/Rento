import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/expense_model.dart';
import 'package:rento/data/repository/firestore_expense_repository.dart';

part 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final FirestoreExpenseRepository expenseRepository;

  ExpenseCubit(this.expenseRepository) : super(ExpenseInitial());

  Future<void> loadExpenses() async {
    emit(ExpenseLoading());
    try {
      final expenses = await expenseRepository.getAllExpenses();
      emit(ExpenseLoaded(expenses));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await expenseRepository.addExpense(expense);
      emit(ExpenseAdded());
      await loadExpenses();
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await expenseRepository.updateExpense(expense);
      emit(ExpenseUpdated());
      await loadExpenses();
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await expenseRepository.deleteExpense(id);
      emit(ExpenseDeleted());
      await loadExpenses();
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<Map<String, double>> getTotalExpensesByMonth() async {
    try {
      return await expenseRepository.getTotalExpensesByMonth();
    } catch (e) {
      emit(ExpenseError(e.toString()));
      return {};
    }
  }

  Future<Object> getTotalExpenses() async {
    try {
      return await expenseRepository.getTotalExpenses();
    } catch (e) {
      emit(ExpenseError(e.toString()));
      return 0.0;
    }
  }

  Future<Map<String, double>> getExpensesByType(DateTime startDate, DateTime endDate) async {
    try {
      return await expenseRepository.getExpensesByType(startDate, endDate);
    } catch (e) {
      emit(ExpenseError(e.toString()));
      return {};
    }
  }
}

