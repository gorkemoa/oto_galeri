import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oto_galeri/core/utils/logger.dart';
import 'package:oto_galeri/models/report_summary_model.dart';
import 'package:oto_galeri/models/vehicle_profit_report_model.dart';
import 'package:oto_galeri/services/reports_service.dart';

/// ReportsViewModel - Raporlar ekranı state yönetimi
class ReportsViewModel extends ChangeNotifier {
  final ReportsService _reportsService = ReportsService();

  // ─── STATE ────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;

  // ─── FİLTRE STATE ─────────────────────────────────────
  String selectedPeriod = 'Bu Yıl';
  int selectedTab = 0; // 0 = Özet, 1 = Araç Bazlı

  static const List<String> periods = ['Bu Ay', 'Son 3 Ay', 'Bu Yıl', 'Tümü'];

  // ─── VERİ ─────────────────────────────────────────────
  ReportSummaryModel? summary;
  List<VehicleProfitReportModel> vehicleProfits = [];
  List<Map<String, dynamic>> monthlyProfitData = [];
  List<Map<String, dynamic>> expenseDistributionData = [];

  // ─── INIT ─────────────────────────────────────────────
  Future<void> init({bool isFilter = false}) async {
    if (!isFilter) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await _reportsService.getReport(period: selectedPeriod);
      result.fold(
        onSuccess: (data) {
          summary = data.summary;
          vehicleProfits = data.vehicles;
          monthlyProfitData = data.monthlyProfit;
          expenseDistributionData = data.expenseDistribution;
        },
        onFailure: (error) {
          AppLogger.error('Raporlar yüklenemedi', error: error);
          errorMessage = error.userMessage;
        },
      );
    } catch (e) {
      AppLogger.error('ReportsViewModel init hatası', error: e);
      errorMessage = 'Raporlar yüklenirken bir hata oluştu.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── REFRESH ──────────────────────────────────────────
  Future<void> refresh() async => init();

  // ─── LOAD MORE ────────────────────────────────────────
  Future<void> loadMore() async {}

  // ─── ON RETRY ─────────────────────────────────────────
  Future<void> onRetry() async => init();

  // ─── DÖNEM SEÇ ────────────────────────────────────────
  void setPeriod(String period) {
    if (selectedPeriod == period) return;
    selectedPeriod = period;
    notifyListeners(); // Butonun rengini ANINDA değiştir
    init(isFilter: true); // Veriyi arka planda yükle
  }

  // ─── TAB SEÇ ──────────────────────────────────────────
  void setTab(int tab) {
    selectedTab = tab;
    notifyListeners();
  }

  // ─── CSV EXPORT ───────────────────────────────────────
  /// Araç bazlı kârlılık verilerini CSV olarak panoya kopyalar.
  Future<void> exportCsv() async {
    final buf = StringBuffer();
    buf.writeln(
        'Araç,Plaka,Yıl,Durum,Alış Fiyatı,Op. Gider,Finansman Gideri,Satış Geliri,Net Kâr/Zarar');
    for (final v in vehicleProfits) {
      buf.writeln([
        _csvCell(v.vehicleName),
        _csvCell(v.plate),
        v.year?.toString() ?? '',
        v.status ?? '',
        _num(v.purchaseCost),
        _num(v.operationExpenses),
        _num(v.financingCost),
        v.isSold ? _num(v.saleRevenue) : '',
        v.isSold ? _num(v.profitLoss) : '',
      ].join(','));
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
  }

  String _csvCell(String? val) {
    if (val == null) return '';
    if (val.contains(',') || val.contains('"') || val.contains('\n')) {
      return '"${val.replaceAll('"', '""')}"';
    }
    return val;
  }

  String _num(double? v) => v?.toStringAsFixed(0) ?? '0';
}

