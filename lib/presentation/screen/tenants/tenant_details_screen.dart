import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/tenant_model.dart';
import 'package:rento/data/repository/firestore_payment_repository.dart';
import 'package:rento/domain/cubit/payment_cubit.dart';
import 'package:rento/presentation/screen/tenants/tenant_report_service.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../widget/payment_item.dart';
import '../payments/add_edit_payment_screen.dart';
import 'add_edit_tenant_screen.dart';

class TenantDetailsScreen extends StatefulWidget {
  final TenantModel tenant;

  const TenantDetailsScreen({super.key, required this.tenant});

  @override
  State<TenantDetailsScreen> createState() => _TenantDetailsScreenState();
}

class _TenantDetailsScreenState extends State<TenantDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PaymentCubit _paymentCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _paymentCubit = PaymentCubit(context.read<FirestorePaymentRepository>());

    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _paymentCubit.loadPaymentsByTenant(widget.tenant.id!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _paymentCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _paymentCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tenant.fullName),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'البيانات'),
              Tab(text: 'سجل الدفع'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                await TenantReportService.generateTenantReport(
                  tenant: widget.tenant,
                  context: context, payments: [],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditTenantScreen(tenant: widget.tenant),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditPaymentScreen(tenantId: widget.tenant.id!),
              ),
            );
            if (result == true && _tabController.index == 1) {
              _paymentCubit.loadPaymentsByTenant(widget.tenant.id!);
            }
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTenantInfo(),
            _buildPaymentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantInfo() {
    final tenant = widget.tenant;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow('رقم الشقة', tenant.apartmentNumber),
                  _buildInfoRow('رقم الجوال', tenant.phoneNumber),
                  _buildInfoRow('قيمة الإيجار',
                      '${tenant.rentAmount.toStringAsFixed(2)} ر.ي'),
                  _buildInfoRow('تاريخ بداية العقد',
                      _formatDate(tenant.contractStartDate)),
                  _buildInfoRow('تاريخ نهاية العقد',
                      _formatDate(tenant.contractEndDate)),
                  if (tenant.notes != null)
                    _buildInfoRow('ملاحظات', tenant.notes!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (tenant.contractImagePath != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('صورة العقد', style: AppStyles.heading3),
                    const SizedBox(height: 8),
                    _buildContractImage(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContractImage() {
    final path = widget.tenant.contractImagePath!;
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: path.startsWith('assets/')
          ? Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildErrorWidget(),
      )
          : Image.file(
        File(path),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildErrorWidget(),
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

  Widget _buildPaymentsList() {
    final tenant = widget.tenant;

    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        if (state is PaymentLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PaymentError) {
          return Center(child: Text(state.message));
        } else if (state is PaymentLoaded) {
          final payments = state.payments;
          if (payments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 64, color: AppColors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد مدفوعات مسجلة',
                      style: TextStyle(color: AppColors.grey)),
                ],
              ),
            );
          }

          double totalPaid = payments.fold(0, (sum, p) => sum + p.amount);
          final months = (tenant.contractEndDate.year -
              tenant.contractStartDate.year) *
              12 +
              tenant.contractEndDate.month -
              tenant.contractStartDate.month +
              1;
          double totalDue = months * tenant.rentAmount;
          double remaining = totalDue - totalPaid;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ملخص الدفع', style: AppStyles.heading3),
                      const SizedBox(height: 8),
                      _buildInfoRow('إجمالي الإيجار المستحق',
                          '${totalDue.toStringAsFixed(2)} ر.ي'),
                      _buildInfoRow('المبلغ المدفوع',
                          '${totalPaid.toStringAsFixed(2)} ر.ي'),
                      _buildInfoRow('المتبقي', '${remaining.toStringAsFixed(2)} ر.ي',
                          valueColor:
                          remaining > 0 ? Colors.red : Colors.green),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...payments.map((p) => PaymentItem(payment: p)),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style:
              AppStyles.bodyText1.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value,
                style: AppStyles.bodyText1.copyWith(color: valueColor)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}