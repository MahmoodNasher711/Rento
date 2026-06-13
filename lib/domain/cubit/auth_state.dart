import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

class AuthUnverified extends AuthState {
  final User user;
  const AuthUnverified(this.user);
}

class AuthUnauthenticated extends AuthState {
  final bool isFirstTime;
  const AuthUnauthenticated({this.isFirstTime = false});
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
