import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/data/models/contract_model.dart';
import 'package:rento/domain/cubit/contract_cubit.dart';
import 'package:rento/domain/cubit/tenant_cubit.dart';

import '../../widget/custom_app_bar.dart';
import '../../widget/custom_dropdown.dart';
import '../../widget/custom_image_picker.dart';

class AddEditContractScreen extends StatefulWidget {
  final ContractModel? contract;

  const AddEditContractScreen({super.key, this.contract});

  @override
  State<AddEditContractScreen> createState() => _AddEditContractScreenState();
}

class _AddEditContractScreenState extends State<AddEditContractScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _tenantId; // bridge: TenantModel.id is now String?
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _tenantId = widget.contract?.tenantId; // contract.tenantId is String now
    _filePath = widget.contract?.filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.contract == null ? 'إضافة عقد جديد' : 'تعديل بيانات العقد',
        actions: [
          if (widget.contract != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteContract,
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
                    final tenants = state.tenants;
                    return CustomDropdown<String>(
                      labelText: 'المستأجر',
                      value: _tenantId,
                      items: tenants
                          .map((tenant) => DropdownMenuItem<String>(
                        value: tenant.id,
                        child: Text('${tenant.fullName} - ${tenant.apartmentNumber}'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _tenantId = value; // String? id
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'يجب اختيار المستأجر';
                        }
                        return null;
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 16),
              CustomImagePicker(
                labelText: 'ملف العقد',
                imagePath: _filePath,
                onImagePicked: (path) {
                  setState(() {
                    _filePath = path;
                  });
                },
                validator: (value) {
                  if (_filePath == null) {
                    return 'يجب رفع ملف العقد';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveContract,
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveContract() async {
    if (_formKey.currentState!.validate()) {
      final contract = ContractModel(
        id: widget.contract?.id,
        tenantId: _tenantId!, // No more int.tryParse, it's String now
        filePath: _filePath!,
        uploadDate: DateTime.now(),
      );

      final cubit = context.read<ContractCubit>();
      if (widget.contract == null) {
        await cubit.addContract(contract);
      } else {
        await cubit.updateContract(contract);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _deleteContract() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا العقد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.contract != null && mounted) {
      await context.read<ContractCubit>().deleteContract(widget.contract!.id!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
