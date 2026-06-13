import 'package:cloud_firestore/cloud_firestore.dart';

class TenantModel {
  final String? id;               // Firestore Document ID (ثابت) أو int من SQLite محوّل لـ String
  final String fullName;
  final String apartmentNumber;   // للعرض فقط — لا يُستخدم كمرجع للعلاقات
  final String? apartmentId;      // Firestore Apartment ID (المرجع الرسمي للعلاقة)
  final String phoneNumber;
  final double rentAmount;
  final DateTime contractStartDate;
  final DateTime contractEndDate;
  final String? notes;
  final String? contractImagePath;
  final bool isPaymentReminderEnabled;
  final bool isActive;            // هل المستأجر نشط؟
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TenantModel({
    this.id,
    required this.fullName,
    required this.apartmentNumber,
    this.apartmentId,
    required this.phoneNumber,
    required this.rentAmount,
    required this.contractStartDate,
    required this.contractEndDate,
    this.notes,
    this.contractImagePath,
    this.isPaymentReminderEnabled = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// fromMap يقبل:
  /// - بيانات SQLite: map['id'] يكون int → يُحوَّل لـ String
  /// - بيانات Firestore: docId يُمرَّر صراحةً من doc.id
  factory TenantModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return TenantModel(
      id: docId ?? map['id']?.toString(),
      fullName: map['fullName'] ?? '',
      apartmentNumber: map['apartmentNumber'] ?? '',
      apartmentId: map['apartmentId'],
      phoneNumber: map['phoneNumber'] ?? '',
      rentAmount: (map['rentAmount'] as num?)?.toDouble() ?? 0.0,
      contractStartDate: _parseDate(map['contractStartDate']),
      contractEndDate: _parseDate(map['contractEndDate']),
      notes: map['notes'],
      contractImagePath: map['contractImagePath'],
      isPaymentReminderEnabled: map['isPaymentReminderEnabled'] == 1 ||
          map['isPaymentReminderEnabled'] == true,
      isActive: map['isActive'] == 1 || map['isActive'] == true || map['isActive'] == null,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  /// toMap() يُستخدم لـ:
  /// - SQLite: id لا يُضمَّن (null يسمح بـ auto-increment)
  /// - Firestore: يُضاف id صراحةً من قِبَل FirestoreTenantRepository
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'apartmentNumber': apartmentNumber,
      if (apartmentId != null) 'apartmentId': apartmentId,
      'phoneNumber': phoneNumber,
      'rentAmount': rentAmount,
      'contractStartDate': contractStartDate.toIso8601String(),
      'contractEndDate': contractEndDate.toIso8601String(),
      'notes': notes,
      'contractImagePath': contractImagePath,
      'isPaymentReminderEnabled': isPaymentReminderEnabled ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  TenantModel copyWith({
    String? id,
    String? fullName,
    String? apartmentNumber,
    String? apartmentId,
    String? phoneNumber,
    double? rentAmount,
    DateTime? contractStartDate,
    DateTime? contractEndDate,
    String? notes,
    String? contractImagePath,
    bool? isPaymentReminderEnabled,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TenantModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      apartmentId: apartmentId ?? this.apartmentId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rentAmount: rentAmount ?? this.rentAmount,
      contractStartDate: contractStartDate ?? this.contractStartDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      notes: notes ?? this.notes,
      contractImagePath: contractImagePath ?? this.contractImagePath,
      isPaymentReminderEnabled: isPaymentReminderEnabled ?? this.isPaymentReminderEnabled,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is Timestamp) return value.toDate();
    return null;
  }
}