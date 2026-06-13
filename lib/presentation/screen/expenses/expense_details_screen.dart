import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rento/data/models/expense_model.dart';
import '../../../constants/app_styles.dart';
import '../../widget/custom_app_bar.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseDetailsScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'تفاصيل المصروف'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('نوع المصروف', expense.type),
                    _buildInfoRow('المبلغ', '${expense.amount.toStringAsFixed(2)} ر.ي'),
                    _buildInfoRow('التاريخ', _formatDate(expense.date)),
                    _buildInfoRow('الوصف', expense.description),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (expense.billImagePath != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('صورة الفاتورة', style: AppStyles.heading3),
                      const SizedBox(height: 8),
                      _buildImageWidget(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: expense.billImagePath!.startsWith('assets/')
          ? Image.asset(
        expense.billImagePath!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      )
          : Image.file(
        File(expense.billImagePath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(height: 8),
          Text('تعذر تحميل الصورة'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: AppStyles.bodyText1.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: AppStyles.bodyText1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}