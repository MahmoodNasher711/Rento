import 'dart:io'; // Add this import
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/payment_model.dart';
import 'package:rento/data/models/tenant_model.dart';
import 'package:rento/domain/cubit/tenant_cubit.dart';

import '../../../constants/app_styles.dart';
import '../../widget/custom_app_bar.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final PaymentModel payment;

  const PaymentDetailsScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'تفاصيل الدفعة'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<TenantCubit, TenantState>(
                  builder: (context, state) {
                    if (state is TenantLoaded) {
                      final tenant = state.tenants.firstWhere(
                            (t) => t.id == payment.tenantId,
                        orElse: () => TenantModel(
                          id: null,
                          fullName: 'غير معروف',
                          apartmentNumber: '--',
                          phoneNumber: '--',
                          rentAmount: 0,
                          contractStartDate: DateTime.now(),
                          contractEndDate: DateTime.now(),
                        ),
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('المستأجر', tenant.fullName),
                          _buildInfoRow('الشقة', tenant.apartmentNumber),
                          _buildInfoRow('الشهر المدفوع', payment.month),
                          _buildInfoRow('المبلغ المدفوع', '${payment.amount.toStringAsFixed(2)} ر.ي'),
                          _buildInfoRow('طريقة الدفع', payment.paymentMethod),
                          _buildInfoRow('تاريخ الدفع', _formatDate(payment.paymentDate)),
                          if (payment.notes != null) _buildInfoRow('ملاحظات', payment.notes!),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (payment.receiptImagePath != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('صورة الإيصال', style: AppStyles.heading3),
                      const SizedBox(height: 8),
                      _buildReceiptImage(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptImage() {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: payment.receiptImagePath!.startsWith('assets/')
          ? Image.asset(
        payment.receiptImagePath!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      )
          : Image.file(
        File(payment.receiptImagePath!),
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