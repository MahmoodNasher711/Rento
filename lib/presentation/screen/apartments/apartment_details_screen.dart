import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/apartment_model.dart';
import 'package:rento/data/models/tenant_model.dart';
import 'package:rento/domain/cubit/tenant_cubit.dart';

import '../../../constants/app_styles.dart';
import '../../widget/custom_app_bar.dart';

class ApartmentDetailsScreen extends StatelessWidget {
  final ApartmentModel apartment;

  const ApartmentDetailsScreen({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'تفاصيل الشقة'),
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
                    _buildInfoRow('رقم الشقة', apartment.number),
                    _buildInfoRow('الحالة', apartment.isRented ? 'مؤجرة' : 'فارغة'),
                    if (apartment.isRented)
                      BlocBuilder<TenantCubit, TenantState>(
                        builder: (context, state) {
                          if (state is TenantLoaded) {
                            final tenant = state.tenants.firstWhere(
                                  (t) => t.id?.toString() == apartment.tenantId,
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
                              children: [
                                const SizedBox(height: 8),
                                _buildInfoRow('المستأجر', tenant.fullName),
                                _buildInfoRow('قيمة الإيجار', '${tenant.rentAmount.toStringAsFixed(2)} ر.ي'),
                                _buildInfoRow('تاريخ نهاية العقد', _formatDate(tenant.contractEndDate)),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
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