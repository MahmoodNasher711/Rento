import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/payment_model.dart';
import 'package:rento/domain/cubit/payment_cubit.dart';
import '../../constants/app_styles.dart';
import '../../presentation/screen/payments/add_edit_payment_screen.dart';
import '../../presentation/screen/payments/payment_details_screen.dart'; // تأكد من استيراد شاشة التفاصيل

class PaymentItem extends StatelessWidget {
  final PaymentModel payment;

  const PaymentItem({super.key, required this.payment});

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
          'دفعة لشهر ${payment.month}',
          style: AppStyles.heading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('المبلغ: ${payment.amount.toStringAsFixed(2)} ر.ي', style: AppStyles.bodyText2),
            const SizedBox(height: 4),
            Text('طريقة الدفع: ${payment.paymentMethod}', style: AppStyles.bodyText2),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.grey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentDetailsScreen(payment: payment),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditPaymentScreen(
                      payment: payment,
                      tenantId: payment.tenantId,
                    ),
                  ),
                ).then((_) {
                  if (!context.mounted) return;
                  context.read<PaymentCubit>().loadPaymentsByTenant(payment.tenantId);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('تأكيد الحذف'),
                    content: const Text('هل تريد حذف هذه الدفعة؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('حذف', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed ?? false) {
                  if (!context.mounted) return;
                  context.read<PaymentCubit>().deletePayment(payment.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}