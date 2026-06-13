import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String? id;             // Firestore Document ID
  final String? apartmentId;    // Optional reference to a specific apartment
  final String type;
  final DateTime date;
  final double amount;
  final String description;
  final String? billImagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpenseModel({
    this.id,
    this.apartmentId,
    required this.type,
    required this.date,
    required this.amount,
    required this.description,
    this.billImagePath,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ExpenseModel(
      id: docId ?? map['id']?.toString(), // التوافق مع SQLite (int -> String)
      apartmentId: map['apartmentId']?.toString(),
      type: map['type'] ?? '',
      date: _parseDate(map['date']),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      billImagePath: map['billImagePath'],
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (apartmentId != null) 'apartmentId': apartmentId,
      'type': type,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
      'billImagePath': billImagePath,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? apartmentId,
    String? type,
    DateTime? date,
    double? amount,
    String? description,
    String? billImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      type: type ?? this.type,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      billImagePath: billImagePath ?? this.billImagePath,
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