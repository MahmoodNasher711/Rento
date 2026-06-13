import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/domain/cubit/apartment_cubit.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../data/models/apartment_model.dart';
import 'add_edit_apartment_screen.dart';
import 'apartment_details_screen.dart';
import '../../widget/empty_state_widget.dart';
import '../../widget/shimmer_widget.dart';
import '../../../utils/ui_helpers.dart';

class ApartmentsScreen extends StatelessWidget {
  const ApartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشقق'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ApartmentCubit>().loadApartments();
            },
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem<String>(value: 'all', child: Text('عرض الكل')),
              const PopupMenuItem<String>(value: 'rented', child: Text('الشقق المؤجرة فقط')),
              const PopupMenuItem<String>(value: 'vacant', child: Text('الشقق الفارغة فقط')),
              const PopupMenuItem<String>(value: 'byFloor', child: Text('تصفية حسب الدور')),
            ],
            onSelected: (value) {
              final cubit = context.read<ApartmentCubit>();
              switch (value) {
                case 'rented':
                  cubit.loadRentedApartments();
                  break;
                case 'vacant':
                  cubit.loadVacantApartments();
                  break;
                case 'byFloor':
                  _showFloorFilterDialog(context, cubit);
                  break;
                default:
                  cubit.loadApartments();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'apartments_fab',
        backgroundColor: AppColors.primary,
        onPressed: () => _navigateToAddApartment(context),
        child: const Icon(Icons.add, color: AppColors.textLight),
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    return BlocConsumer<ApartmentCubit, ApartmentState>(
      listener: (context, state) {
        if (state is ApartmentError) {
          UIHelpers.showErrorSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is ApartmentLoading) {
          return const ShimmerListView();
        } else if (state is ApartmentLoaded) {
          return _buildApartmentsList(context, state.apartments);
        }
        return const Center(child: Text('حدث خطأ غير متوقع'));
      },
    );
  }

  Widget _buildApartmentsList(BuildContext context, List<ApartmentModel> apartments) {
    final cubit = context.read<ApartmentCubit>();

    if (apartments.isEmpty) {
      return EmptyStateWidget(
        type: EmptyStateType.apartments,
        onAction: () => _navigateToAddApartment(context),
        actionLabel: 'إضافة شقة جديدة',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await cubit.loadApartments();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: apartments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final apartment = apartments[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  apartment.floorNumber.toString(),
                  style: AppStyles.heading1.copyWith(color: AppColors.primary),
                ),
              ),
              title: Text('شقة رقم ${apartment.number}', style: AppStyles.bodyText1),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الدور: ${apartment.floorNumber}',
                    style: AppStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    apartment.isRented ? 'مؤجرة' : 'فارغة',
                    style: TextStyle(
                      color: apartment.isRented ? AppColors.apartmentRented : AppColors.apartmentVacant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              onTap: () => _navigateToApartmentDetails(context, apartment),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.info),
                    onPressed: () => _navigateToEditApartment(context, apartment),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.danger),
                    onPressed: () async {
                      final confirmed = await _confirmDelete(context, apartment.number);
                      if (confirmed) {
                        // استخدام apartment.id الثابت بدلاً من apartment.number
                        await cubit.deleteApartment(apartment.id ?? apartment.number);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String apartmentNumber) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الشقة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بحث عن شقة'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'أدخل رقم الشقة أو الدور',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // يمكنك لاحقًا تنفيذ البحث
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _showFloorFilterDialog(BuildContext context, ApartmentCubit cubit) {
    final floorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية حسب الدور'),
        content: TextField(
          controller: floorController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'أدخل رقم الدور',
            prefixIcon: Icon(Icons.apartment),

          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final floorNumber = int.tryParse(floorController.text);
              if (floorNumber != null) {
                cubit.loadApartmentsByFloor(floorNumber);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يجب إدخال رقم دور صحيح')),
                );
              }
            },
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddApartment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditApartmentScreen()),
    ).then((_) {
      if (!context.mounted) return;
      context.read<ApartmentCubit>().loadApartments();
    });
  }

  void _navigateToEditApartment(BuildContext context, ApartmentModel apartment) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditApartmentScreen(apartment: apartment)),
    ).then((_) {
      if (!context.mounted) return;
      context.read<ApartmentCubit>().loadApartments();
    });
  }

  void _navigateToApartmentDetails(BuildContext context, ApartmentModel apartment) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ApartmentDetailsScreen(apartment: apartment)),
    );
  }
}