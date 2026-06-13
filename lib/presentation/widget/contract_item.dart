import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/contract_model.dart';
import 'package:rento/data/models/tenant_model.dart';
import 'package:rento/domain/cubit/tenant_cubit.dart';

import '../../constants/app_styles.dart';
import '../screen/contracts/contract_details_screen.dart';

class ContractItem extends StatelessWidget {
  final ContractModel contract;

  const ContractItem({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: BlocBuilder<TenantCubit, TenantState>(
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
              return Text(
                tenant.fullName,
                style: AppStyles.heading3,
              );
            }
            return const SizedBox();
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'تاريخ الرفع: ${_formatDate(contract.uploadDate)}',
              style: AppStyles.bodyText2,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContractDetailsScreen(contract: contract),
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
