import 'package:oto_galeri/core/network/api_result.dart';
import 'package:oto_galeri/models/expense_model.dart';

/// ExpenseService - Gider/Masraf işlemleri
/// GEÇİCİ: Dummy veri kullanılır. API hazır olduğunda gerçek endpoint entegre edilecek.
class ExpenseService {
  final List<ExpenseModel> _dummyExpenses = [
    ExpenseModel.fromJson({
      'id': 1,
      'vehicle_id': 1,
      'vehicle_name': 'BMW 320i',
      'vehicle_brand': 'BMW',
      'vehicle_model': '320i',
      'type': 'Lastik',
      'amount': 12000.0,
      'date': '2026-02-20',
      'description': '4 adet kış lastiği değişimi',
    }),
    ExpenseModel.fromJson({
      'id': 2,
      'vehicle_id': 1,
      'vehicle_name': 'BMW 320i',
      'vehicle_brand': 'BMW',
      'vehicle_model': '320i',
      'type': 'Servis',
      'amount': 18000.0,
      'date': '2026-02-22',
      'description': 'Periyodik bakım',
    }),
    ExpenseModel.fromJson({
      'id': 3,
      'vehicle_id': 2,
      'vehicle_name': 'Mercedes C180',
      'vehicle_brand': 'Mercedes',
      'vehicle_model': 'C180',
      'type': 'Noter',
      'amount': 8500.0,
      'date': '2026-02-21',
      'description': 'Noter devir masrafı',
    }),
    ExpenseModel.fromJson({
      'id': 4,
      'vehicle_id': 2,
      'vehicle_name': 'Mercedes C180',
      'vehicle_brand': 'Mercedes',
      'vehicle_model': 'C180',
      'type': 'Ekspertiz',
      'amount': 3500.0,
      'date': '2026-02-20',
      'description': 'Detaylı ekspertiz raporu',
    }),
   
  ];

  // ─── TÜM GİDERLER ─────────────────────────────────────
  Future<ApiResult<List<ExpenseModel>>> getExpenses({
    int? vehicleId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // TODO: API hazır olduğunda gerçek endpoint entegre edilecek
    await Future.delayed(const Duration(milliseconds: 500));

    var filtered = List<ExpenseModel>.from(_dummyExpenses);

    if (vehicleId != null) {
      filtered = filtered.where((e) => e.vehicleId == vehicleId).toList();
    }

    if (type != null && type.isNotEmpty) {
      filtered = filtered.where((e) => e.type == type).toList();
    }

    return ApiResult.success(filtered);
  }

  // ─── MASRAF EKLE ───────────────────────────────────────
  Future<ApiResult<ExpenseModel>> addExpense(Map<String, dynamic> data) async {
    // TODO: API hazır olduğunda gerçek endpoint entegre edilecek
    await Future.delayed(const Duration(milliseconds: 500));

    final newExpense = ExpenseModel.fromJson({
      ...data,
      'id': _dummyExpenses.length + 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    _dummyExpenses.add(newExpense);
    return ApiResult.success(newExpense);
  }
}
