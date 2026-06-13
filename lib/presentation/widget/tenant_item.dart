import 'package:flutter/material.dart';
import 'package:rento/data/models/tenant_model.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import 'package:rento/main.dart';

class TenantItem extends StatelessWidget {
  final TenantModel tenant;
  const TenantItem({required this.tenant, super.key});

  Widget _buildStatusChip() {
    final now = DateTime.now();
    final difference = tenant.contractEndDate.difference(now).inDays;
    
    String label;
    Color color;
    
    if (difference < 0) {
      label = 'منتهي';
      color = AppColors.contractEnded;
    } else if (difference <= 30) {
      label = 'ينتهي قريباً';
      color = AppColors.contractEnding;
    } else {
      label = 'نشط';
      color = AppColors.contractActive;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(tenant.fullName, style: AppStyles.bodyText1)),
            _buildStatusChip(),
          ],
        ),
        subtitle: Text(
          'شقة ${tenant.apartmentNumber} - ${tenant.phoneNumber}',
          style: AppStyles.bodyText2,
        ),
        trailing: Text(
          '${tenant.rentAmount} ر.ي',
          style: AppStyles.bodyText1.copyWith(color: AppColors.primary),
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.tenantDetails,
          arguments: tenant,
        ),
      ),
    );
  }
}