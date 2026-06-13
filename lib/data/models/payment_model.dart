import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String? id;             // Firestore Document ID
  final String tenantId;        // Firestore Tenant ID (المرجع الرسمي)
  final String month;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? receiptImagePath;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    this.id,
    required this.tenantId,
    required this.month,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.receiptImagePath,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return PaymentModel(
      id: docId ?? map['id']?.toString(), // التوافق مع SQLite (int -> String)
      tenantId: map['tenantId'].toString(),
      month: map['month'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? '',
      paymentDate: _parseDate(map['paymentDate']),
      receiptImagePath: map['receiptImagePath'],
      notes: map['notes'],
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tenantId': tenantId,
      'month': month,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(),
      'receiptImagePath': receiptImagePath,
      'notes': notes,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? tenantId,
    String? month,
    double? amount,
    String? paymentMethod,
    DateTime? paymentDate,
    String? receiptImagePath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      notes: notes ?? this.notes,
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