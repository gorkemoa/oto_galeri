import 'package:flutter/material.dart';
import 'package:oto_galeri/core/utils/logger.dart';

/// ReportsViewModel - Raporlar ekranı state yönetimi
class ReportsViewModel extends ChangeNotifier {
  // ─── STATE ────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;

  // Grafik verileri - API hazır olduğunda modeller eklenecek
  List<Map<String, dynamic>>? monthlyProfitData;
  List<Map<String, dynamic>>? expenseDistributionData;
  List<Map<String, dynamic>>? mostProfitableData;
  List<Map<String, dynamic>>? mostExpenseData;

  // ─── INIT ─────────────────────────────────────────────
  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // TODO: API hazır olduğunda gerçek service çağrılacak
      await Future.delayed(const Duration(milliseconds: 500));

      // Geçici dummy grafik verileri
      monthlyProfitData = [
        {'month': 'Oca', 'profit': 180000.0},
        {'month': 'Şub', 'profit': 250000.0},
        {'month': 'Mar', 'profit': 320000.0},
      ];

      expenseDistributionData = [
        {'type': 'Servis', 'amount': 85000.0},
        {'type': 'Lastik', 'amount': 42000.0},
        {'type': 'Noter', 'amount': 35000.0},
        {'type': 'Tamir', 'amount': 62000.0},
        {'type': 'Yakıt', 'amount': 18000.0},
        {'type': 'Temizlik', 'amount': 8000.0},
      ];

     
    } catch (e) {
      AppLogger.error('Raporlar init hatası', error: e);
      errorMessage = 'Raporlar yüklenirken bir hata oluştu.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── REFRESH ──────────────────────────────────────────
  Future<void> refresh() async {
    await init();
  }

  // ─── RETRY ────────────────────────────────────────────
  Future<void> onRetry() async {
    await init();
  }
}
