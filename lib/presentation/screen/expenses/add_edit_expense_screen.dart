import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/expense_model.dart';
import 'package:rento/domain/cubit/expense_cubit.dart';
import 'package:rento/utils/ui_helpers.dart';
import 'package:rento/constants/app_colors.dart';

import '../../widget/custom_app_bar.dart';
import '../../widget/custom_text_field.dart';
import '../../widget/custom_date_picker.dart';
import '../../widget/custom_image_picker.dart';
import '../../widget/custom_dropdown.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String? _type;
  DateTime? _date;
  String? _billImagePath;

  final List<String> _expenseTypes = ['صيانة', 'كهرباء', 'ماء', 'تنظيف', 'أخرى'];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );
    _type = widget.expense?.type;
    _date = widget.expense?.date;
    _billImagePath = widget.expense?.billImagePath;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.expense == null ? 'إضافة مصروف جديد' : 'تعديل بيانات المصروف',
        actions: [
          if (widget.expense != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteExpense,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomDropdown<String>(
                labelText: 'نوع المصروف',
                value: _type,
                items: _expenseTypes
                    .map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب اختيار نوع المصروف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountController,
                labelText: 'المبلغ',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب إدخال المبلغ';
                  }
                  if (double.tryParse(value) == null) {
                    return 'يجب إدخال قيمة رقمية';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomDatePicker(
                labelText: 'التاريخ',
                initialDate: _date,
                onDateSelected: (date) {
                  setState(() {
                    _date = date;
                  });
                },
                validator: (value) {
                  if (_date == null) {
                    return 'يجب اختيار التاريخ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'الوصف',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب إدخال وصف المصروف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomImagePicker(
                labelText: 'صورة الفاتورة',
                imagePath: _billImagePath,
                onImagePicked: (path) {
                  setState(() {
                    _billImagePath = path;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = ExpenseModel(
        id: widget.expense?.id,
        type: _type!,
        amount: double.parse(_amountController.text),
        date: _date!,
        description: _descriptionController.text,
        billImagePath: _billImagePath,
      );

      try {
        final cubit = context.read<ExpenseCubit>();
        if (widget.expense == null) {
          await cubit.addExpense(expense);
        } else {
          await cubit.updateExpense(expense);
        }

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

  void _deleteExpense() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟'),
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

    if (confirmed == true && widget.expense != null && mounted) {
      try {
        await context.read<ExpenseCubit>().deleteExpense(widget.expense!.id!);
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
