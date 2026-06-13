import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/apartment_model.dart';
import 'package:rento/presentation/widget/custom_app_bar.dart';
import 'package:rento/presentation/widget/custom_text_field.dart';
import 'package:rento/utils/ui_helpers.dart';
import 'package:rento/constants/app_colors.dart';

import '../../../domain/cubit/apartment_cubit.dart';

class AddEditApartmentScreen extends StatefulWidget {
  final ApartmentModel? apartment;

  const AddEditApartmentScreen({super.key, this.apartment});

  @override
  State<AddEditApartmentScreen> createState() => _AddEditApartmentScreenState();
}

class _AddEditApartmentScreenState extends State<AddEditApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberController;
  late TextEditingController _floorController;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(
      text: widget.apartment?.number ?? '',
    );
    _floorController = TextEditingController(
      text: widget.apartment?.floorNumber.toString() ?? '1',
    );
  }

  @override
  void dispose() {
    _numberController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.apartment == null ? 'إضافة شقة جديدة' : 'تعديل بيانات الشقة',
        actions: [
          if (widget.apartment != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteApartment,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _numberController,
                labelText: 'رقم الشقة',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب إدخال رقم الشقة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _floorController,
                labelText: 'رقم الدور',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب إدخال رقم الدور';
                  }
                  if (int.tryParse(value) == null) {
                    return 'يجب أن يكون رقم الدور صحيحًا';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveApartment,
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveApartment() async {
    if (_formKey.currentState!.validate()) {
      try {
        final cubit = context.read<ApartmentCubit>();
        final apartment = ApartmentModel(
          id: widget.apartment?.id, // الحفاظ على الـ ID الثابت عند التعديل
          number: _numberController.text,
          floorNumber: int.parse(_floorController.text),
          isRented: widget.apartment?.isRented ?? false,
          tenantId: widget.apartment?.tenantId,
        );

        if (widget.apartment == null) {
          await cubit.addApartment(apartment);
        } else {
          await cubit.updateApartment(apartment);
        }

        if (mounted) {
          UIHelpers.showSuccessSnackBar(context, 'تم الحفظ بنجاح');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(context, 'حدث خطأ: ${e.toString()}');
        }
      }
    }
  }

  void _deleteApartment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الشقة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.apartment != null && mounted) {
      try {
        // استخدام الـ id الثابت بدلاً من number للحذف
        final idToDelete = widget.apartment!.id ?? widget.apartment!.number;
        await context.read<ApartmentCubit>().deleteApartment(idToDelete);
        if (mounted) {
          UIHelpers.showSuccessSnackBar(context, 'تم الحذف بنجاح');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(context, 'حدث خطأ: ${e.toString()}');
        }
      }
    }
  }
}