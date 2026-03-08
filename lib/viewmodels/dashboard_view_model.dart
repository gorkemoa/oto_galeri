import 'package:flutter/material.dart';
import 'package:oto_galeri/models/dashboard_summary_model.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/models/alert_model.dart';
import 'package:oto_galeri/services/dashboard_service.dart';
import 'package:oto_galeri/core/utils/logger.dart';

/// DashboardViewModel - Ana sayfa state yönetimi
/// Her ViewModel yalnızca bir ekrana hizmet eder.
class DashboardViewModel extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  // ─── STATE ────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;
  DashboardSummaryModel? summary;
  List<VehicleModel>? recentVehicles;
  List<AlertModel>? upcomingAlerts;

  // ─── INIT ─────────────────────────────────────────────
  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Paralel yükle
      final results = await Future.wait([
        _service.getSummary(),
        _service.getRecentVehicles(),
        _service.getUpcomingAlerts(),
      ]);

      results[0].fold(
        onSuccess: (data) => summary = data as DashboardSummaryModel,
        onFailure: (error) {
          AppLogger.error('Dashboard summary yüklenemedi', error: error);
          errorMessage = error.userMessage;
        },
      );

      results[1].fold(
        onSuccess: (data) => recentVehicles = data as List<VehicleModel>,
        onFailure: (error) {
          AppLogger.error('Son eklenen araçlar yüklenemedi', error: error);
          errorMessage ??= error.userMessage;
        },
      );

      results[2].fold(
        onSuccess: (data) => upcomingAlerts = data as List<AlertModel>,
        onFailure: (error) {
          AppLogger.error('Yaklaşan uyarılar yüklenemedi', error: error);
          errorMessage ??= error.userMessage;
        },
      );
    } catch (e) {
      AppLogger.error('Dashboard init hatası', error: e);
      errorMessage = 'Veriler yüklenirken bir hata oluştu.';
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
