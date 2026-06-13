import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/domain/cubit/payment_cubit.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import 'add_edit_payment_screen.dart';
import 'payment_details_screen.dart';
import '../../widget/empty_state_widget.dart';
import '../../widget/shimmer_widget.dart';

// تعريف RouteObserver (يفضل يكون في main.dart ويتم مشاركته، هنا فقط للتوضيح)
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with RouteAware {
  late PaymentCubit paymentCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    paymentCubit = context.read<PaymentCubit>();
    paymentCubit.loadPayments();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // تُنفذ عند العودة من شاشة أخرى إلى هذه الشاشة
    paymentCubit.loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الإيجارات'),
      ),
      body: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const ShimmerListView();
          } else if (state is PaymentError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.danger)));
          } else if (state is PaymentLoaded) {
            if (state.payments.isEmpty) {
              return EmptyStateWidget(
                type: EmptyStateType.payments,
                actionLabel: 'إضافة دفعة جديدة',
                onAction: () async {
                  // We might need tenant ID for new payment, or let the AddEditPaymentScreen handle it
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditPaymentScreen(tenantId: ''), // Use '' or handle in screen
                    ),
                  );
                  if (result == true) {
                    paymentCubit.loadPayments();
                  }
                },
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.payments.length,
              itemBuilder: (context, index) {
                final payment = state.payments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${payment.amount.toStringAsFixed(2)} ر.ي',
                      style: AppStyles.bodyText1,
                    ),
                    subtitle: Text('تاريخ: ${payment.paymentDate.toLocal().toString().split(' ')[0]}'),
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
}
