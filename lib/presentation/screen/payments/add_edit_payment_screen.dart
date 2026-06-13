import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rento/data/models/payment_model.dart';
import 'package:rento/domain/cubit/payment_cubit.dart';
import 'package:rento/domain/cubit/tenant_cubit.dart';
import 'package:rento/utils/ui_helpers.dart';
import 'package:rento/constants/app_colors.dart';

import '../../../constants/app_styles.dart';
import '../../../data/models/tenant_model.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_date_picker.dart';
import '../../widget/custom_dropdown.dart';
import '../../widget/custom_image_picker.dart';
import '../../widget/custom_text_field.dart';

class AddEditPaymentScreen extends StatefulWidget {
  final String tenantId;
  final PaymentModel? payment;

  const AddEditPaymentScreen({
    super.key,
    required this.tenantId,
    this.payment,
  });

  @override
  State<AddEditPaymentScreen> createState() => _AddEditPaymentScreenState();
}

class _AddEditPaymentScreenState extends State<AddEditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _monthController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  String? _paymentMethod;
  DateTime? _paymentDate;
  String? _receiptImagePath;
  String? _selectedTenantId;
  final List<String> methods = ['نقدي', 'تحويل بنكي'];

  @override
  void initState() {
    super.initState();
    _selectedTenantId = widget.tenantId.isNotEmpty ? widget.tenantId : null;
    _monthController = TextEditingController(
      text: widget.payment?.month ?? DateFormat('yyyy-MM').format(DateTime.now()),
    );
    _amountController = TextEditingController(
      text: widget.payment?.amount.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.payment?.notes ?? '',
    );
    _paymentMethod = widget.payment?.paymentMethod;
    _paymentDate = widget.payment?.paymentDate;
    _receiptImagePath = widget.payment?.receiptImagePath;
  }

  @override
  void dispose() {
    _monthController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.payment == null ? 'إضافة دفعة جديدة' : 'تعديل بيانات الدفعة',
        actions: [
          if (widget.payment != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deletePayment,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              BlocBuilder<TenantCubit, TenantState>(
                builder: (context, state) {
                  if (state is TenantLoaded) {
                    if (widget.tenantId.isEmpty) {
                      // Show Dropdown if we don't have a specific tenant yet
                      return Column(
                        children: [
                          CustomDropdown<String>(
                            labelText: 'المستأجر',
                            value: _selectedTenantId,
                            items: state.tenants.map((t) => DropdownMenuItem<String>(
                              value: t.id,
                              child: Text('${t.fullName} - شقة ${t.apartmentNumber}'),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedTenantId = val),
                            validator: (val) => val == null ? 'يجب اختيار المستأجر' : null,
                          ),
                        ],
                      );
                    } else {
                      // Show specific tenant card
                      final tenant = state.tenants.firstWhere(
                            (t) => t.id == widget.tenantId,
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
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('المستأجر: ${tenant.fullName}', style: AppStyles.bodyText1),
                              const SizedBox(height: 8),
                              Text('الشقة: ${tenant.apartmentNumber}', style: AppStyles.bodyText1),
                              const SizedBox(height: 8),
                              Text('قيمة الإيجار: ${tenant.rentAmount.toStringAsFixed(2)} ر.ي', style: AppStyles.bodyText1),
                            ],
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _monthController,
                labelText: 'الشهر المدفوع',
                hintText: 'yyyy-MM',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب إدخال الشهر المدفوع';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountController,
                labelText: 'المبلغ المدفوع',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب إدخال المبلغ المدفوع';
                  }
                  if (double.tryParse(value) == null) {
                    return 'يجب إدخال قيمة رقمية';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                labelText: 'طريقة الدفع',
                value: _paymentMethod,
                items: methods
                    .map((method) => DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب اختيار طريقة الدفع';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                labelText: 'تاريخ الدفع',
                initialDate: _paymentDate,
                onDateSelected: (date) {
                  setState(() {
                    _paymentDate = date;
                  });
                },
                validator: (value) {
                  if (_paymentDate == null) {
                    return 'يجب اختيار تاريخ الدفع';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomImagePicker(
                labelText: 'صورة الإيصال',
                imagePath: _receiptImagePath,
                onImagePicked: (path) {
                  setState(() {
                    _receiptImagePath = path;
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
                  onPressed: _savePayment,
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePayment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTenantId == null || _selectedTenantId!.isEmpty) {
        UIHelpers.showErrorSnackBar(context, 'يجب تحديد المستأجر');
        return;
      }

      final payment = PaymentModel(
        id: widget.payment?.id,
        tenantId: _selectedTenantId!,
        month: _monthController.text,
        amount: double.parse(_amountController.text),
        paymentMethod: _paymentMethod!,
        paymentDate: _paymentDate!,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        receiptImagePath: _receiptImagePath,
      );

      try {
        final cubit = context.read<PaymentCubit>();
        if (widget.payment == null) {
          await cubit.addPayment(payment);
        } else {
          await cubit.updatePayment(payment);
        }

        if (mounted) {
          UIHelpers.showSuccessSnackBar(context, 'تم الحفظ بنجاح');
          Navigator.pop(context, true); // ✅ RETURN TRUE TO REFRESH
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(context, 'حدث خطأ أثناء الحفظ: $e');
        }
      }
    }
  }

  void _deletePayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الدفعة؟'),
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

    if (confirmed == true && widget.payment != null && mounted) {
      try {
        await context.read<PaymentCubit>().deletePayment(widget.payment!.id!);
        if (mounted) {
          UIHelpers.showSuccessSnackBar(context, 'تم الحذف بنجاح');
          Navigator.pop(context, true); // ✅ RETURN TRUE TO REFRESH
        }
      } catch (e) {
        if (mounted) {
          UIHelpers.showErrorSnackBar(context, 'حدث خطأ أثناء الحذف: $e');
        }
      }
    }
  }
}
