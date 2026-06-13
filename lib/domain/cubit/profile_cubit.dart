import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/auth_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository authRepository;

  ProfileCubit({required this.authRepository})
      : super(ProfileInitial());

  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());
      final user = await authRepository.getUserProfile();
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(const ProfileError('لم يتم العثور على بيانات المستخدم.'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({String? fullName, bool? notificationsEnabled, String? language, String? themeMode}) async {
    try {
      emit(ProfileLoading());
      await authRepository.updateUserProfile(
        fullName: fullName,
        notificationsEnabled: notificationsEnabled,
        language: language,
        themeMode: themeMode,
      );
      // Reload profile after update
      await loadProfile();
    } catch (e) {
      emit(ProfileError(e.toString()));
      // Fallback to reload
      await loadProfile();
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    try {
      emit(ProfileImageUploading());
      final url = await authRepository.uploadProfileImage(imageFile);
      emit(ProfileImageUploaded(url));
      // Reload profile to get updated photoUrl
      await loadProfile();
    } catch (e) {
      emit(ProfileError(e.toString()));
      await loadProfile();
    }
  }
}
