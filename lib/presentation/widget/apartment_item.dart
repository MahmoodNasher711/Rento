import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/apartment_model.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../data/models/tenant_model.dart';
import '../../domain/cubit/tenant_cubit.dart';

class ApartmentItem extends StatelessWidget {
  final ApartmentModel apartment;
  final VoidCallback? onTap;

  const ApartmentItem({
    super.key,
    required this.apartment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // ... باقي الكود
      child: ListTile(
        // ... باقي الكود
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'الحالة: ${apartment.isRented ? 'مؤجرة' : 'فارغة'}',
              style: AppStyles.bodyText2.copyWith(
                color: apartment.isRented ? AppColors.success : AppColors.danger,
              ),
            ),
            if (apartment.isRented)
              FutureBuilder<TenantModel?>(
                future: _getTenantForApartment(context, apartment.tenantId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'المستأجر: ${snapshot.data?.fullName ?? 'غير معروف'}',
                      style: AppStyles.bodyText2,
                    );
                  }
                  return const SizedBox();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<TenantModel?> _getTenantForApartment(BuildContext context, String? tenantId) async {
    if (tenantId == null || tenantId.isEmpty) return null;
    return await context.read<TenantCubit>().getTenantById(tenantId);
  }
}