import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String photoUrl;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool notificationsEnabled;
  final String role;
  final String accountStatus;
  final String subscriptionPlan;
  final String subscriptionStatus;
  final String fcmToken;
  final String language;
  final String themeMode;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl = '',
    this.emailVerified = false,
    this.createdAt,
    this.lastLoginAt,
    this.notificationsEnabled = true,
    this.role = 'owner',
    this.accountStatus = 'active',
    this.subscriptionPlan = 'free',
    this.subscriptionStatus = 'active',
    this.fcmToken = '',
    this.language = 'ar',
    this.themeMode = 'system',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      role: map['role'] ?? 'owner',
      accountStatus: map['accountStatus'] ?? 'active',
      subscriptionPlan: map['subscriptionPlan'] ?? 'free',
      subscriptionStatus: map['subscriptionStatus'] ?? 'active',
      fcmToken: map['fcmToken'] ?? '',
      language: map['language'] ?? 'ar',
      themeMode: map['themeMode'] ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : FieldValue.serverTimestamp(),
      'notificationsEnabled': notificationsEnabled,
      'role': role,
      'accountStatus': accountStatus,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStatus': subscriptionStatus,
      'fcmToken': fcmToken,
      'language': language,
      'themeMode': themeMode,
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? photoUrl,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? notificationsEnabled,
    String? role,
    String? accountStatus,
    String? subscriptionPlan,
    String? subscriptionStatus,
    String? fcmToken,
    String? language,
    String? themeMode,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      fcmToken: fcmToken ?? this.fcmToken,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
