import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/domain/cubit/tenant_cubit.dart';

import '../../../constants/app_colors.dart';
import '../../widget/tenant_item.dart';
import 'add_edit_tenant_screen.dart';
import '../../widget/empty_state_widget.dart';
import '../../widget/shimmer_widget.dart';

class TenantsScreen extends StatelessWidget {
  const TenantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستأجرين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
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
              builder: (context) => const AddEditTenantScreen(),
            ),
          );

          // إذا تمت الإضافة بنجاح، أعد تحميل المستأجرين
          if (result == true) {
            if (!context.mounted) return;
            context.read<TenantCubit>().loadTenants();
          }
        },
        child: const Icon(Icons.add, color: AppColors.textLight),
      ),
      body: BlocBuilder<TenantCubit, TenantState>(
        builder: (context, state) {
          if (state is TenantLoading) {
            return const ShimmerListView();
          } else if (state is TenantError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.danger)));
          } else if (state is TenantLoaded) {
            if (state.tenants.isEmpty) {
              return EmptyStateWidget(
                type: EmptyStateType.tenants,
                actionLabel: 'إضافة مستأجر جديد',
                onAction: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditTenantScreen(),
                    ),
                  );
                  if (result == true) {
                    if (!context.mounted) return;
                    context.read<TenantCubit>().loadTenants();
                  }
                },
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tenants.length,
              itemBuilder: (context, index) {
                final tenant = state.tenants[index];
                return TenantItem(tenant: tenant);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
