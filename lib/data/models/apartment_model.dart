class ApartmentModel {
  final String? id; // Firestore Document ID (ثابت وعشوائي)
  final String number; // رقم الشقة (حقل قابل للتعديل)
  final int floorNumber;
  final bool isRented;
  final String? tenantId; // سيرتبط بـ Firestore tenantId في المستقبل

  ApartmentModel({
    this.id,
    required this.number,
    required this.floorNumber,
    bool? isRented,
    this.tenantId,
  }) : isRented = isRented ?? tenantId != null;

  ApartmentModel copyWith({
    String? id,
    String? number,
    int? floorNumber,
    bool? isRented,
    String? tenantId,
  }) {
    return ApartmentModel(
      id: id ?? this.id,
      number: number ?? this.number,
      floorNumber: floorNumber ?? this.floorNumber,
      isRented: isRented ?? this.isRented,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  factory ApartmentModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ApartmentModel(
      id: docId ?? map['id'], // نأخذ الـ docId من Firestore أو من الـ Map (SQLite)
      number: map['number'],
      floorNumber: map['floorNumber'] ?? 0,
      tenantId: map['tenantId'],
      isRented: map['isRented'] == 1 || map['isRented'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // نحفظ الـ id داخل الوثيقة لسهولة الجلب
      'number': number,
      'floorNumber': floorNumber,
      'isRented': isRented ? 1 : 0,
      'tenantId': tenantId,
    };
  }
}