import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/repository/firestore_expense_repository.dart';
import 'package:rento/domain/cubit/expense_cubit.dart';
import 'package:rento/presentation/screen/expenses/expense_details_screen.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import 'add_edit_expense_screen.dart';
import '../../widget/empty_state_widget.dart';
import '../../widget/shimmer_widget.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseCubit(context.read<FirestoreExpenseRepository>()),
      child: _ExpensesView(),
    );
  }
}

class _ExpensesView extends StatefulWidget {
  @override
  State<_ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<_ExpensesView> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات بعد انتهاء بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseCubit>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المصاريف'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditExpenseScreen(),
            ),
          ).then((_) {
            if (!context.mounted) return;
            context.read<ExpenseCubit>().loadExpenses();
          });
        },
        child: const Icon(Icons.add, color: AppColors.textLight),
      ),
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const ShimmerListView();
          } else if (state is ExpenseError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.danger)));
          } else if (state is ExpenseLoaded) {
            if (state.expenses.isEmpty) {
              return EmptyStateWidget(
                type: EmptyStateType.expenses,
                actionLabel: 'إضافة مصروف جديد',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditExpenseScreen(),
                    ),
                  ).then((_) {
                    if (!context.mounted) return;
                    context.read<ExpenseCubit>().loadExpenses();
                  });
                },
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.expenses.length,
              itemBuilder: (context, index) {
                final expense = state.expenses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      expense.type,
                      style: AppStyles.heading3,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          '${expense.amount.toStringAsFixed(2)} ر.ي',
                          style: AppStyles.bodyText2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(expense.date),
                          style: AppStyles.bodyText2,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline, color: AppColors.grey),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExpenseDetailsScreen(expense: expense),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.info),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditExpenseScreen(expense: expense),
                              ),
                            ).then((_) {
                      if (!context.mounted) return;
                      context.read<ExpenseCubit>().loadExpenses();
                    });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.danger),
                          onPressed: () async {
                            final confirmed = await _showDeleteConfirmationDialog(context);
                            if (confirmed) {
                              if (!context.mounted) return;
                              context.read<ExpenseCubit>().deleteExpense(expense.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
