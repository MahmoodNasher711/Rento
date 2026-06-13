import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rento/data/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthCubit({required this.authRepository}) : super(const AuthInitial()) {
    _init();
  }

  void _init() async {
    _userSubscription = authRepository.user.listen((user) async {
      if (user == null) {
        final isFirstTime = await authRepository.isFirstTime();
        emit(AuthUnauthenticated(isFirstTime: isFirstTime));
      } else {
        await user.reload(); // Refresh token and email status
        if (user.emailVerified) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnverified(user));
        }
      }
    });
  }

  Future<void> completeOnboarding() async {
    await authRepository.setFirstTimeCompleted();
    emit(const AuthUnauthenticated(isFirstTime: false));
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      emit(const AuthLoading());
      await authRepository.signIn(email: email, password: password);
      // State is updated via stream listener
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      // Re-evaluate current state so we don't get stuck in error
      _checkCurrentState();
    }
  }

  Future<void> signUp({required String email, required String password, required String fullName}) async {
    try {
      emit(const AuthLoading());
      await authRepository.signUp(email: email, password: password, fullName: fullName);
      // State is updated via stream listener
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      _checkCurrentState();
    }
  }

  Future<void> signOut() async {
    try {
      emit(const AuthLoading());
      await authRepository.signOut();
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      emit(const AuthLoading());
      await authRepository.resetPassword(email: email);
      _checkCurrentState();
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      _checkCurrentState();
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await authRepository.sendEmailVerification();
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      _checkCurrentState();
    }
  }

  Future<void> checkEmailVerified() async {
    try {
      emit(const AuthLoading());
      final isVerified = await authRepository.checkEmailVerified();
      if (isVerified) {
        final user = authRepository.currentUser;
        if (user != null) {
          emit(AuthAuthenticated(user));
        }
      } else {
        final user = authRepository.currentUser;
        if (user != null) {
          emit(AuthUnverified(user));
        }
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      _checkCurrentState();
    }
  }

  void _checkCurrentState() async {
    final user = authRepository.currentUser;
    if (user == null) {
      final isFirstTime = await authRepository.isFirstTime();
      emit(AuthUnauthenticated(isFirstTime: isFirstTime));
    } else {
      if (user.emailVerified) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnverified(user));
      }
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
