import 'package:oto_galeri/core/network/api_result.dart';
import 'package:oto_galeri/models/dashboard_summary_model.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/models/alert_model.dart';

/// DashboardService - Dashboard verilerini yönetir
/// GEÇİCİ: Dummy veri kullanılır. API hazır olduğunda gerçek endpoint entegre edilecek.
class DashboardService {
  // ─── DASHBOARD ÖZET ────────────────────────────────────
  Future<ApiResult<DashboardSummaryModel>> getSummary() async {
    // TODO: API hazır olduğunda gerçek endpoint entegre edilecek
    // final response = await ApiClient().get(ApiConstants.dashboardSummary);
    await Future.delayed(const Duration(milliseconds: 500));

    final dummyJson = {
      'total_vehicles': 34,
      'in_stock_vehicles': 12,
      'sold_vehicles': 22,
      'total_profit': 1240000.0,
    };

    return ApiResult.success(DashboardSummaryModel.fromJson(dummyJson));
  }

  // ─── SON EKLENEN ARAÇLAR ───────────────────────────────
  Future<ApiResult<List<VehicleModel>>> getRecentVehicles() async {
    // TODO: API hazır olduğunda gerçek endpoint entegre edilecek
    await Future.delayed(const Duration(milliseconds: 500));

    final dummyList = [
      {
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
        'inspection_date': '2026-03-12',
        'image_url': 'assets/images/vehicles/bmw_3_serisi.png',
        'created_at': '2026-03-01T10:00:00',
      },
      {
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
        'image_url': 'assets/images/vehicles/mercedes_c200.png',
        'created_at': '2026-03-02T14:00:00',
      },
    
    ];

    final vehicles = dummyList.map((json) => VehicleModel.fromJson(json)).toList();
    return ApiResult.success(vehicles);
  }

  // ─── YAKLAŞAN UYARILAR ────────────────────────────────
  Future<ApiResult<List<AlertModel>>> getUpcomingAlerts() async {
    // TODO: API hazır olduğunda gerçek endpoint entegre edilecek
    await Future.delayed(const Duration(milliseconds: 300));

    final dummyList = [
      {
        'id': 1,
        'vehicle_id': 1,
        'vehicle_name': 'BMW 320i',
        'image_url': 'assets/images/vehicles/bmw_3_serisi.png',
        'alert_type': 'sigorta',
        'due_date': '2026-03-19',
        'remaining_days': 12,
      },
      {
        'id': 2,
        'vehicle_id': 1,
        'vehicle_name': 'BMW 320i',
        'image_url': 'assets/images/vehicles/bmw_3_serisi.png',
        'alert_type': 'muayene',
        'due_date': '2026-03-12',
        'remaining_days': 5,
      },
    ];

    final alerts = dummyList.map((json) => AlertModel.fromJson(json)).toList();
    return ApiResult.success(alerts);
  }
}
