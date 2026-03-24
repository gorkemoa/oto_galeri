import 'package:oto_galeri/models/vehicle_usage_model.dart';

/// VehicleUsageService - Demo araç kullanım kaydı servisi
/// Singleton in-memory store; API hazır olduğunda HTTP katmanıyla değiştirilecek.
class VehicleUsageService {
  static final VehicleUsageService _instance = VehicleUsageService._();
  factory VehicleUsageService() => _instance;
  VehicleUsageService._();

  final Map<int, List<VehicleUsageModel>> _storage = {};
  int _idCounter = 1;

  // ─── DEMO VERİ ────────────────────────────────────────────────────────────

  /// Demo personel listesi – API bağlandığında backend'den gelecek.
  static const List<String> mockStaffList = [
    'Ali Yılmaz',
    'Mehmet Kaya',
    'Ahmet Demir',
    'Fatma Şahin',
    'Emre Çelik',
  ];

  /// Kullanıma bağlı gider türleri – HGS ve trafik cezası.
  static const List<String> usageExpenseTypes = [
    'HGS / Otoyol',
    'Trafik Cezası',
  ];

  // ─── OKUMA ────────────────────────────────────────────────────────────────

  /// Araca ait kullanım kayıtları (tarih azalan sıra)
  List<VehicleUsageModel> getUsageForVehicle(int vehicleId) {
    final records = List<VehicleUsageModel>.from(_storage[vehicleId] ?? []);
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  /// Araca ait en güncel km değeri (son bitiş km'si)
  int? getLatestKm(int vehicleId) {
    final records = (_storage[vehicleId] ?? [])
        .where((r) => r.endKm != null)
        .toList();
    if (records.isEmpty) return null;
    records.sort((a, b) => b.date.compareTo(a.date));
    return records.first.endKm;
  }

  // ─── YAZMA ────────────────────────────────────────────────────────────────

  Future<VehicleUsageModel> addUsage({
    required int vehicleId,
    required DateTime date,
    required String staffName,
    int? startKm,
    int? endKm,
    String? expenseType,
    double? expenseAmount,
    String? description,
  }) async {
    // Demo: kısa gecikme simülasyonu
    await Future.delayed(const Duration(milliseconds: 300));

    final record = VehicleUsageModel(
      id: _idCounter++,
      vehicleId: vehicleId,
      date: date,
      staffName: staffName,
      startKm: startKm,
      endKm: endKm,
      expenseType: expenseType,
      expenseAmount: expenseAmount,
      description: description,
    );
    _storage.putIfAbsent(vehicleId, () => []).add(record);
    return record;
  }
}
