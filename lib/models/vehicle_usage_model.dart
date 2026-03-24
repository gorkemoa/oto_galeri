/// VehicleUsageModel - Araç kullanım kaydı modeli
/// Demo aşamasında local/mock state ile çalışır.
/// API hazır olduğunda toJson/fromJson ile backend'e bağlanacak.
class VehicleUsageModel {
  final int id;
  final int vehicleId;
  final DateTime date;
  final String staffName; // Kullanan personel
  final int? startKm; // Kullanım başlangıç km
  final int? endKm; // Kullanım bitiş km
  final String? expenseType; // 'HGS / Otoyol' | 'Trafik Cezası'
  final double? expenseAmount; // Gider tutarı (TL)
  final String? description; // Açıklama

  const VehicleUsageModel({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.staffName,
    this.startKm,
    this.endKm,
    this.expenseType,
    this.expenseAmount,
    this.description,
  });

  /// Net kullanılan km (bitiş - başlangıç)
  int? get usedKm {
    if (startKm != null && endKm != null && endKm! > startKm!) {
      return endKm! - startKm!;
    }
    return null;
  }

  /// Gider var mı?
  bool get hasExpense =>
      expenseType != null && expenseType!.isNotEmpty && expenseAmount != null;

  // API hazır olduğunda toJson / fromJson buraya eklenecek.
}
