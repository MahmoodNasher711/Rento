import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rento/domain/cubit/auth_cubit.dart';
import 'package:rento/domain/cubit/profile_cubit.dart';
import 'package:rento/domain/cubit/profile_state.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_spacing.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (!mounted) return;
        await context.read<ProfileCubit>().uploadProfileImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الصورة: $e')),
        );
      }
    }
  }

  void _editName(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل الاسم'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'أدخل الاسم الجديد'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<ProfileCubit>().updateProfile(fullName: controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProfileImageUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفع الصورة بنجاح!')),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileImageUploading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: user.photoUrl.isNotEmpty
                              ? NetworkImage(user.photoUrl) as ImageProvider
                              : const AssetImage('assets/images/placeholder.png'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickAndUploadImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    user.fullName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Verification Badge
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: user.emailVerified ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          user.emailVerified ? Icons.check_circle : Icons.warning,
                          color: user.emailVerified ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            user.emailVerified
                                ? 'البريد الإلكتروني موثق'
                                : 'يرجى توثيق البريد الإلكتروني',
                            style: TextStyle(
                              color: user.emailVerified ? Colors.green[800] : Colors.orange[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!user.emailVerified)
                          TextButton(
                            onPressed: () {
                              context.read<AuthCubit>().sendEmailVerification();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إرسال رابط التوثيق')),
                              );
                            },
                            child: const Text('إرسال الرابط'),
                          )
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Settings Sections
                  _buildSectionTitle('إعدادات الحساب'),
                  _buildListTile(
                    icon: Icons.person_outline,
                    title: 'تعديل الاسم',
                    onTap: () => _editName(user.fullName),
                  ),
                  _buildListTile(
                    icon: Icons.lock_outline,
                    title: 'تغيير كلمة المرور',
                    onTap: () {
                      context.read<AuthCubit>().resetPassword(email: user.email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إرسال رابط إعادة تعيين كلمة المرور')),
                      );
                    },
                  ),
                  
                  const Divider(),
                  _buildSectionTitle('التفضيلات'),
                  _buildSwitchTile(
                    icon: Icons.notifications_none,
                    title: 'الإشعارات',
                    value: user.notificationsEnabled,
                    onChanged: (val) {
                      context.read<ProfileCubit>().updateProfile(notificationsEnabled: val);
                    },
                  ),
                  _buildListTile(
                    icon: Icons.color_lens_outlined,
                    title: 'المظهر',
                    trailing: Text(user.themeMode == 'dark' ? 'داكن' : (user.themeMode == 'light' ? 'فاتح' : 'تلقائي')),
                    onTap: () {
                      // Show Theme Picker
                    },
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          elevation: 0,
                        ),
                        onPressed: () {
                          context.read<AuthCubit>().signOut();
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('تسجيل الخروج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            );
          }

          return const Center(child: Text('لا توجد بيانات'));
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
    );
  }
}
