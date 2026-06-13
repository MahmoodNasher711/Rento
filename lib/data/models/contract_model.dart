import 'package:cloud_firestore/cloud_firestore.dart';

class ContractModel {
  final String? id;             // Firestore Document ID
  final String tenantId;        // Firestore Tenant ID (المرجع الرسمي)
  final String filePath;
  final DateTime uploadDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ContractModel({
    this.id,
    required this.tenantId,
    required this.filePath,
    required this.uploadDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ContractModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ContractModel(
      id: docId ?? map['id']?.toString(), // التوافق مع SQLite (int -> String)
      tenantId: map['tenantId'].toString(),
      filePath: map['filePath'] ?? '',
      uploadDate: _parseDate(map['uploadDate']),
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tenantId': tenantId,
      'filePath': filePath,
      'uploadDate': uploadDate.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  ContractModel copyWith({
    String? id,
    String? tenantId,
    String? filePath,
    DateTime? uploadDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContractModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      filePath: filePath ?? this.filePath,
      uploadDate: uploadDate ?? this.uploadDate,
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