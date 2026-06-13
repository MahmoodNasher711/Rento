import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rento/constants/app_colors.dart';
import 'package:rento/domain/cubit/auth_cubit.dart';
import 'package:rento/domain/cubit/auth_state.dart';
import 'package:rento/main.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: GoogleFonts.cairo()), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: () => context.read<AuthCubit>().signOut(),
              child: Text('تسجيل الخروج', style: GoogleFonts.cairo(color: AppColors.danger, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const Icon(Icons.mark_email_unread_rounded, size: 100, color: AppColors.primary),
                  const SizedBox(height: 32),
                  Text(
                    'تم إنشاء حسابك بنجاح 🎉',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لقد أرسلنا رسالة تحقق إلى بريدك الإلكتروني.\n\nيرجى فتح بريدك الإلكتروني والضغط على رابط التحقق لتفعيل حسابك.\n\nإذا لم تجد الرسالة، تحقق من مجلد الرسائل غير المرغوب فيها (Spam).',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لن تتمكن من استخدام التطبيق حتى يتم تفعيل البريد الإلكتروني.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 48),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: isLoading ? null : () {
                                context.read<AuthCubit>().checkEmailVerified();
                              },
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text('لقد قمت بالتحقق', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: isLoading ? null : () {
                                context.read<AuthCubit>().sendEmailVerification();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم إعادة إرسال رسالة التحقق'), backgroundColor: AppColors.success),
                                );
                              },
                              child: Text('إعادة إرسال رسالة التحقق', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}
