import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/contract_model.dart';
import 'package:rento/data/models/tenant_model.dart';
import 'package:rento/domain/cubit/tenant_cubit.dart';

import '../../../constants/app_styles.dart';
import '../../widget/custom_app_bar.dart';

class ContractDetailsScreen extends StatelessWidget {
  final ContractModel contract;

  const ContractDetailsScreen({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'تفاصيل العقد'),
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
                            (t) => t.id == contract.tenantId,
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
                          _buildInfoRow('تاريخ الرفع', _formatDate(contract.uploadDate)),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ملف العقد', style: AppStyles.heading3),
                    const SizedBox(height: 8),
                    Image.asset(
                      contract.filePath,
                      width: double.infinity,
                      height: 500,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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