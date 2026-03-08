/// ExpenseModel - Gider/Masraf modeli
class ExpenseModel {
  final int? id;
  final int? vehicleId;
  final String? vehicleName; // Araç adı (liste görünümü için)
  final String? vehicleBrand; // Araç markası (görsel için)
  final String? vehicleModel; // Araç modeli (görsel için)
  final String? type; // Noter, Servis, Lastik, Yakıt, Tamir, Temizlik, Ekspertiz
  final double? amount; // Tutar
  final DateTime? date; // Tarih
  final String? description; // Açıklama
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExpenseModel({
    this.id,
    this.vehicleId,
    this.vehicleName,
    this.vehicleBrand,
    this.vehicleModel,
    this.type,
    this.amount,
    this.date,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int?,
      vehicleId: json['vehicle_id'] as int?,
      vehicleName: json['vehicle_name'] as String?,
      vehicleBrand: json['vehicle_brand'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      type: json['type'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'vehicle_name': vehicleName,
      'vehicle_brand': vehicleBrand,
      'vehicle_model': vehicleModel,
      'type': type,
      'amount': amount,
      'date': date?.toIso8601String(),
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
