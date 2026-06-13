import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/tenant_model.dart';
import 'package:rento/domain/cubit/tenant_cubit.dart';
import 'package:rento/domain/cubit/apartment_cubit.dart';
import 'package:rento/data/models/apartment_model.dart';
import 'package:rento/utils/ui_helpers.dart';
import 'package:rento/constants/app_colors.dart';

import '../../widget/custom_app_bar.dart';
import '../../widget/custom_date_picker.dart';
import '../../widget/custom_image_picker.dart';
import '../../widget/custom_text_field.dart';
import '../../widget/custom_dropdown.dart';

class AddEditTenantScreen extends StatefulWidget {
  final TenantModel? tenant;

  const AddEditTenantScreen({super.key, this.tenant});

  @override
  State<AddEditTenantScreen> createState() => _AddEditTenantScreenState();
}

class _AddEditTenantScreenState extends State<AddEditTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _rentAmountController;
  late TextEditingController _notesController;
  DateTime? _contractStartDate;
  DateTime? _contractEndDate;
  String? _contractImagePath;
  String? _selectedApartmentNumber;
  List<ApartmentModel> _apartments = [];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.tenant?.fullName ?? '');
    _phoneNumberController = TextEditingController(text: widget.tenant?.phoneNumber ?? '');
    _rentAmountController = TextEditingController(text: widget.tenant?.rentAmount.toString() ?? '');
    _notesController = TextEditingController(text: widget.tenant?.notes ?? '');
    _contractStartDate = widget.tenant?.contractStartDate;
    _contractEndDate = widget.tenant?.contractEndDate;
    _contractImagePath = widget.tenant?.contractImagePath;
    _selectedApartmentNumber = widget.tenant?.apartmentNumber;

    if (widget.tenant != null) {
      // لو في تعديل: نجيب كل الشقق عشان نعرض الفارغة + الشقة الحالية حتى لو مأجورة
      context.read<ApartmentCubit>().loadApartments();
    } else {
      // إضافة جديد: نجيب الشقق الفارغة فقط
      context.read<ApartmentCubit>().loadVacantApartments();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _rentAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.tenant == null ? 'إضافة مستأجر جديد' : 'تعديل بيانات المستأجر',
        actions: [
          if (widget.tenant != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTenant,
            ),
        ],
      ),
      body: BlocConsumer<ApartmentCubit, ApartmentState>(
        listener: (context, state) {
          if (state is ApartmentLoaded) {
            final allApartments = state.apartments;

            // عرض الشقق الفارغة + الشقة المختارة (لو موجودة)
            final filteredApartments = allApartments.where((apt) {
              return !apt.isRented || apt.number == _selectedApartmentNumber;
            }).toList();

            setState(() {
              _apartments = filteredApartments;
            });
          }
        },
        builder: (context, state) {
          if (state is ApartmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApartmentError) {
            return Center(child: Text('حدث خطأ: ${state.message}'));
          }

          if (state is ApartmentInitial || state is ApartmentAdded ||
              state is ApartmentUpdated || state is ApartmentDeleted) {
            // إعادة تحميل البيانات إذا لزم الأمر
            context.read<ApartmentCubit>().loadVacantApartments();
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'الاسم الكامل',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يجب إدخال الاسم الكامل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dropdown لاختيار رقم الشقة (الشقق الفارغة + شقة المستأجر لو تعديل)
                  CustomDropdown<String>(
                    labelText: 'رقم الشقة',
                    value: _selectedApartmentNumber,
                    items: _apartments
                        .map((apartment) => DropdownMenuItem<String>(
                      value: apartment.number,
                      child: Text(apartment.number),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedApartmentNumber = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يجب اختيار رقم الشقة';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneNumberController,
                    labelText: 'رقم الجوال',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يجب إدخال رقم الجوال';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _rentAmountController,
                    labelText: 'قيمة الإيجار',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يجب إدخال قيمة الإيجار';
                      }
                      if (double.tryParse(value) == null) {
                        return 'يجب إدخال قيمة رقمية';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDatePicker(
                    labelText: 'تاريخ بداية العقد',
                    initialDate: _contractStartDate,
                    onDateSelected: (date) {
                      setState(() {
                        _contractStartDate = date;
                      });
                    },
                    validator: (value) {
                      if (_contractStartDate == null) {
                        return 'يجب اختيار تاريخ بداية العقد';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDatePicker(
                    labelText: 'تاريخ نهاية العقد',
                    initialDate: _contractEndDate,
                    onDateSelected: (date) {
                      setState(() {
                        _contractEndDate = date;
                      });
                    },
                    validator: (value) {
                      if (_contractEndDate == null) {
                        return 'يجب اختيار تاريخ نهاية العقد';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomImagePicker(
                    labelText: 'صورة العقد',
                    imagePath: _contractImagePath,
                    onImagePicked: (path) {
                      setState(() {
                        _contractImagePath = path;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _notesController,
                    labelText: 'ملاحظات',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveTenant,
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveTenant() async {
    if (_formKey.currentState!.validate()) {
      // Find the corresponding apartment to get its ID
      final selectedApt = _apartments.firstWhere(
        (apt) => apt.number == _selectedApartmentNumber,
        orElse: () => ApartmentModel(id: null, number: _selectedApartmentNumber!, floorNumber: 0),
      );

      final tenant = TenantModel(
        id: widget.tenant?.id,
        fullName: _fullNameController.text,
        apartmentNumber: _selectedApartmentNumber!,
        apartmentId: selectedApt.id, // <-- Here is the missing link!
        phoneNumber: _phoneNumberController.text,
        rentAmount: double.parse(_rentAmountController.text),
        contractStartDate: _contractStartDate!,
        contractEndDate: _contractEndDate!,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        contractImagePath: _contractImagePath,
        isPaymentReminderEnabled: widget.tenant?.isPaymentReminderEnabled ?? false,
      );

      try {
        final cubit = context.read<TenantCubit>();
        if (widget.tenant == null) {
          await cubit.addTenant(tenant);
        } else {
          await cubit.updateTenant(tenant);
        }
        if (!mounted) return;
        final apartmentCubit = context.read<ApartmentCubit>();
        await apartmentCubit.loadVacantApartments();

        if (mounted) {
          UIHelpers.showSuccessSnackBar(context, 'تم الحفظ بنجاح');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(context, 'حدث خطأ أثناء الحفظ: $e');
        }
      }
    }
  }

  void _deleteTenant() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المستأجر؟'),
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

    if (confirmed == true && widget.tenant != null && mounted) {
      try {
        await context.read<TenantCubit>().deleteTenant(
          widget.tenant!.id!,
        );
        if (mounted) {
          UIHelpers.showSuccessSnackBar(context, 'تم الحذف بنجاح');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(context, 'حدث خطأ أثناء الحذف: $e');
        }
      }
    }
  }
}
