import 'package:flutter/material.dart';
import 'package:rento/data/models/expense_model.dart';

import '../../constants/app_styles.dart';
import '../screen/expenses/expense_details_screen.dart';

class ExpenseItem extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
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
              'المبلغ: ${expense.amount.toStringAsFixed(2)} ر.ي',
              style: AppStyles.bodyText2,
            ),
            const SizedBox(height: 4),
            Text(
              'التاريخ: ${_formatDate(expense.date)}',
              style: AppStyles.bodyText2,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseDetailsScreen(expense: expense),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
