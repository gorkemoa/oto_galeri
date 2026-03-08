import 'package:oto_galeri/core/network/api_result.dart';
import 'package:oto_galeri/models/vehicle_model.dart';

/// VehicleService - Araç CRUD işlemleri
/// GEÇİCİ: Dummy veri kullanılır. API hazır olduğunda gerçek endpoint entegre edilecek.
class VehicleService {
  // Dummy araç listesi (geçici)
  final List<VehicleModel> _dummyVehicles = [
    VehicleModel.fromJson({
      'id': 1,
      'brand': 'BMW',
      'model': '320i',
      'year': 2018,
      'kilometer': 145000,
      'fuel_type': 'Benzin',
      'color': 'Beyaz',
      'plate': '34 ABC 123',
      'purchase_price': 1120000.0,
      'purchase_date': '2026-02-15',
      'payment_method': 'Nakit',
      'status': 'STOKTA',
      'total_expense': 45000.0,
      'insurance_date': '2026-03-19',
      'kasko_date': '2026-06-15',
      'inspection_date': '2026-03-12',
      'created_at': '2026-03-01T10:00:00',
    }),
    VehicleModel.fromJson({
      'id': 2,
      'brand': 'Mercedes',
      'model': 'C180',
      'year': 2019,
      'kilometer': 98000,
      'fuel_type': 'Dizel',
      'color': 'Siyah',
      'plate': '06 DEF 456',
      'purchase_price': 1350000.0,
      'purchase_date': '2026-02-20',
      'payment_method': 'Çek',
      'status': 'STOKTA',
      'total_expense': 28000.0,
      'insurance_date': '2026-08-10',
      'kasko_date': '2026-09-20',
      'inspection_date': '2026-07-15',
      'created_at': '2026-03-02T14:00:00',
    }),
    VehicleModel.fromJson({
      'id': 3,
      'brand': 'BMW',
      'model': 'X5',
      'year': 2022,
      'kilometer': 38000,
      'fuel_type': 'Dizel',
      'color': 'Mavi',
      'plate': '34 XY 5050',
      'purchase_price': 3200000.0,
      'purchase_date': '2026-01-20',
      'payment_method': 'Nakit',
      'status': 'STOKTA',
      'total_expense': 12000.0,
      'insurance_date': '2026-09-15',
      'kasko_date': '2026-09-15',
      'inspection_date': '2027-01-20',
      'created_at': '2026-01-20T10:00:00',
    }),
    VehicleModel.fromJson({
      'id': 4,
      'brand': 'Audi',
      'model': 'A3',
      'year': 2019,
      'kilometer': 112000,
      'fuel_type': 'Benzin',
      'color': 'Beyaz',
      'plate': '19 DD 015',
      'purchase_price': 1050000.0,
      'purchase_date': '2026-02-10',
      'payment_method': 'Çek',
      'status': 'STOKTA',
      'total_expense': 23000.0,
      'insurance_date': '2026-07-10',
      'inspection_date': '2026-06-01',
      'created_at': '2026-02-10T11:00:00',
    }),
    VehicleModel.fromJson({
      'id': 5,
      'brand': 'Audi',
      'model': 'A6',
      'year': 2021,
      'kilometer': 65000,
      'fuel_type': 'Benzin',
      'color': 'Siyah',
      'plate': '34 AU 6060',
      'purchase_price': 2100000.0,
      'purchase_date': '2026-02-25',
      'payment_method': 'Nakit',
      'status': 'SATILDI',
      'total_expense': 9000.0,
      'sale_price': 2400000.0,
      'sale_date': '2026-03-06',
      'sale_payment_method': 'Nakit',
      'customer_name': 'Emre Arslan',
      'customer_phone': '0555 321 00 11',
      'customer_balance': 0.0,
      'created_at': '2026-02-25T09:00:00',
    }),
    VehicleModel.fromJson({
      'id': 6,
      'brand': 'Mercedes',
      'model': 'E200',
      'year': 2020,
      'kilometer': 87000,
      'fuel_type': 'Benzin',
      'color': 'Beyaz',
      'plate': '06 ME 2020',
      'purchase_price': 1750000.0,
      'purchase_date': '2026-03-01',
      'payment_method': 'Vadeli',
      'status': 'STOKTA',
      'total_expense': 31000.0,
      'insurance_date': '2026-10-01',
      'kasko_date': '2026-10-01',
      'inspection_date': '2026-12-15',
      'created_at': '2026-03-01T14:00:00',
    }),
  ];

  // ─── ARAÇ LİSTESİ ─────────────────────────────────────
  Future<ApiResult<List<VehicleModel>>> getVehicles({
    String? search,
    String? brand,
    String? status,
  }) async {
    // TODO: API hazır olduğunda gerçek endpoint entegre edilecek
    await Future.delayed(const Duration(milliseconds: 500));

    var filtered = List<VehicleModel>.from(_dummyVehicles);

    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      filtered = filtered.where((v) {
        return v.fullName.toLowerCase().contains(query) ||
            (v.plate?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (brand != null && brand.isNotEmpty) {
      filtered = filtered.where((v) => v.brand == brand).toList();
    }

    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((v) => v.status == status).toList();
    }

    return ApiResult.success(filtered);
  }

  // ─── ARAÇ DETAY ────────────────────────────────────────
  Future<ApiResult<VehicleModel>> getVehicleDetail(int id) async {
    // TODO: API hazır olduğunda gerçek endpoint entegre edilecek
    await Future.delayed(const Duration(milliseconds: 300));

    final vehicle = _dummyVehicles.where((v) => v.id == id).firstOrNull;
    if (vehicle != null) {
      return ApiResult.success(vehicle);
    }
    return ApiResult.failure(const ApiException(
      type: ApiErrorType.notFound,
      message: 'Araç bulunamadı.',
      statusCode: 404,
    ));
  }

  // ─── ARAÇ EKLE ─────────────────────────────────────────
  Future<ApiResult<VehicleModel>> addVehicle(Map<String, dynamic> data) async {
    // TODO: API hazır olduğunda gerçek endpoint entegre edilecek
    await Future.delayed(const Duration(milliseconds: 500));

    final newVehicle = VehicleModel.fromJson({
      ...data,
      'id': _dummyVehicles.length + 1,
      'status': 'STOKTA',
      'total_expense': 0.0,
      'created_at': DateTime.now().toIso8601String(),
    });

    _dummyVehicles.add(newVehicle);
    return ApiResult.success(newVehicle);
  }

  // ─── ARAÇ SAT ──────────────────────────────────────────
  Future<ApiResult<VehicleModel>> sellVehicle(int id, Map<String, dynamic> saleData) async {
    // TODO: API hazır olduğunda gerçek endpoint entegre edilecek
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _dummyVehicles.indexWhere((v) => v.id == id);
    if (index == -1) {
      return ApiResult.failure(const ApiException(
        type: ApiErrorType.notFound,
        message: 'Araç bulunamadı.',
        statusCode: 404,
      ));
    }

    // Dummy güncelleme simülasyonu
    return ApiResult.success(_dummyVehicles[index]);
  }
}
