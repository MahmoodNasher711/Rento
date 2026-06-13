import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/domain/cubit/auth_cubit.dart';
import 'package:rento/domain/cubit/auth_state.dart';
import 'package:rento/main.dart';
import 'package:rento/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else if (state is AuthUnverified) {
          Navigator.pushReplacementNamed(context, AppRoutes.verifyEmail);
        } else if (state is AuthUnauthenticated) {
          if (state.isFirstTime) {
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 140,
                height: 140,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.real_estate_agent_rounded,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
