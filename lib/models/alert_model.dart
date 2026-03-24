/// AlertModel - Yaklaşan sigorta/muayene uyarı modeli
class AlertModel {
  final int? id;
  final int? vehicleId;
  final String? vehicleName;
  final String? imageUrl;
  final String? alertType; // sigorta, kasko, muayene
  final DateTime? dueDate;
  final int? remainingDays;
  final DateTime? createdAt;

  const AlertModel({
    this.id,
    this.vehicleId,
    this.vehicleName,
    this.imageUrl,
    this.alertType,
    this.dueDate,
    this.remainingDays,
    this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as int?,
      vehicleId: json['vehicle_id'] as int?,
      vehicleName: json['vehicle_name'] as String?,
      imageUrl: json['image_url'] as String?,
      alertType: json['alert_type'] as String?,
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date']) : null,
      remainingDays: json['remaining_days'] as int?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'vehicle_name': vehicleName,
      'image_url': imageUrl,
      'alert_type': alertType,
      'due_date': dueDate?.toIso8601String(),
      'remaining_days': remainingDays,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
