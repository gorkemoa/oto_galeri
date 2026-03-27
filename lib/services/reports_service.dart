import 'package:oto_galeri/core/network/api_result.dart';
import 'package:oto_galeri/models/report_summary_model.dart';
import 'package:oto_galeri/models/vehicle_profit_report_model.dart';
import 'package:oto_galeri/services/expense_service.dart';
import 'package:oto_galeri/services/vehicle_service.dart';

/// ReportsService - Kârlılık raporu hesaplamaları
/// GEÇİCİ: VehicleService ve ExpenseService'ten dummy verilerle hesaplama yapar.
/// API hazır olduğunda /v1/reports/... endpoint'leri entegre edilecek.
class ReportsService {
  final VehicleService _vehicleService = VehicleService();
  final ExpenseService _expenseService = ExpenseService();

  // ─── ANA RAPOR ────────────────────────────────────────
  /// Dönem filtreli araç kârlılık raporunu döndürür.
  Future<
      ApiResult<
          ({
            ReportSummaryModel summary,
            List<VehicleProfitReportModel> vehicles,
            List<Map<String, dynamic>> monthlyProfit,
            List<Map<String, dynamic>> expenseDistribution,
          })>> getReport({String period = 'Tümü'}) async {
    // API hazır olduğunda gerçek ağ isteği yapılacak. Dummy verilerde gecikme kaldırıldı.
    // await Future.delayed(const Duration(milliseconds: 600));

    try {
      final vehiclesResult = await _vehicleService.getVehicles();
      final expensesResult = await _expenseService.getExpenses();

      List<VehicleProfitReportModel> vehicleProfits = [];
      List<Map<String, dynamic>> expenseDistribution = [];
      List<Map<String, dynamic>> monthlyProfit = [];

      final vehiclesError = vehiclesResult.fold(
        onSuccess: (_) => null,
        onFailure: (e) => e,
      );
      if (vehiclesError != null) {
        return ApiResult.failure(vehiclesError);
      }

      final allVehicles = vehiclesResult.fold(
        onSuccess: (data) => data,
        onFailure: (_) => <dynamic>[],
      );

      final allExpenses = expensesResult.fold(
        onSuccess: (data) => data,
        onFailure: (_) => <dynamic>[],
      );

      // Araç başı gider Haritası (vehicleId → {kategori → tutar})
      final Map<int, Map<String, double>> expenseMap = {};
      for (final expense in allExpenses) {
        if (expense.vehicleId == null) continue;
        expenseMap.putIfAbsent(expense.vehicleId!, () => {});
        final cat = expense.type ?? 'Diğer';
        expenseMap[expense.vehicleId!]![cat] =
            (expenseMap[expense.vehicleId!]![cat] ?? 0) + (expense.amount ?? 0);
      }

      // Gider kategorisi toplam dağılımı (tüm araçlar)
      final Map<String, double> globalExpenseMap = {};
      for (final expense in allExpenses) {
        if (!_isInPeriod(expense.date, period)) continue;
        final cat = expense.type ?? 'Diğer';
        globalExpenseMap[cat] = (globalExpenseMap[cat] ?? 0) + (expense.amount ?? 0);
      }
      // Expense kaydı olmayan araçların toplam masrafını "Diğer" olarak ekle
      for (final vehicle in allVehicles) {
        final relevantDate = vehicle.saleDate ?? vehicle.purchaseDate;
        if (!_isInPeriod(relevantDate, period)) continue;
        final recordedExpense = expenseMap[vehicle.id]
                ?.values
                .fold<double>(0, (a, b) => a + b) ??
            0;
        final vehicleTotalExpense = vehicle.totalExpense ?? 0;
        final unrecorded = vehicleTotalExpense - recordedExpense;
        if (unrecorded > 0) {
          globalExpenseMap['Diğer'] =
              (globalExpenseMap['Diğer'] ?? 0) + unrecorded;
        }
      }
      expenseDistribution = globalExpenseMap.entries
          .map((e) => {'type': e.key, 'amount': e.value})
          .toList()
        ..sort((a, b) =>
            (b['amount'] as double).compareTo(a['amount'] as double));

      // VehicleProfitReportModel listesi
      for (final vehicle in allVehicles) {
        final relevantDate = vehicle.saleDate ?? vehicle.purchaseDate;
        if (!_isInPeriod(relevantDate, period)) continue;

        final catMap = Map<String, double>.from(expenseMap[vehicle.id] ?? {});
        // Kayıt dışı kısımı da "Diğer" olarak ekle
        final recordedTotal =
            catMap.values.fold<double>(0, (a, b) => a + b);
        final vehicleExpenseTotal = vehicle.totalExpense ?? 0;
        final remainder = vehicleExpenseTotal - recordedTotal;
        if (remainder > 0.5) {
          catMap['Diğer'] = (catMap['Diğer'] ?? 0) + remainder;
        }

        vehicleProfits.add(VehicleProfitReportModel(
          vehicleId: vehicle.id,
          vehicleName: vehicle.fullName,
          plate: vehicle.plate,
          year: vehicle.year,
          brand: vehicle.brand,
          model: vehicle.model,
          status: vehicle.status,
          purchaseCost: vehicle.purchasePrice,
          operationExpenses: vehicle.totalExpense,
          financingCost: vehicle.financeChargeAmount ?? 0,
          saleRevenue: vehicle.salePrice,
          purchaseDate: vehicle.purchaseDate,
          saleDate: vehicle.saleDate,
          paymentMethod: vehicle.paymentMethod,
          salePaymentMethod: vehicle.salePaymentMethod,
          expenseByCategory: catMap.isNotEmpty ? catMap : null,
        ));
      }

      // Sıralama: Satılanlar önce (kâra göre desc), sonra stok
      vehicleProfits.sort((a, b) {
        if (a.isSold && !b.isSold) return -1;
        if (!a.isSold && b.isSold) return 1;
        if (a.isSold && b.isSold) {
          return b.profitLoss.compareTo(a.profitLoss);
        }
        return (b.purchaseDate ?? DateTime(0))
            .compareTo(a.purchaseDate ?? DateTime(0));
      });

      // Aylık kâr (satılan araçlar, satış tarihine göre gruplanır)
      final Map<String, double> monthProfitMap = {};
      final soldVehicles =
          vehicleProfits.where((v) => v.isSold && v.saleDate != null).toList();
      for (final v in soldVehicles) {
        final key = _monthKey(v.saleDate!);
        monthProfitMap[key] = (monthProfitMap[key] ?? 0) + v.profitLoss;
      }
      // Tüm ay aralığını doldur
      final months = _buildMonthRange(period);
      monthlyProfit = months.map((m) {
        return {'month': m['label']!, 'profit': monthProfitMap[m['key']] ?? 0.0};
      }).toList();

      // Özet
      final soldList = vehicleProfits.where((v) => v.isSold).toList();
      final stockList = vehicleProfits.where((v) => !v.isSold).toList();
      final totalRevenue = soldList.fold<double>(0, (s, v) => s + (v.saleRevenue ?? 0));
      final totalPurchaseCost = soldList.fold<double>(0, (s, v) => s + (v.purchaseCost ?? 0));
      final totalOpExpenses = soldList.fold<double>(0, (s, v) => s + (v.operationExpenses ?? 0));
      final totalFinancing = soldList.fold<double>(0, (s, v) => s + (v.financingCost ?? 0));
      final netProfit = soldList.fold<double>(0, (s, v) => s + v.profitLoss);
      final stockInvestment = stockList.fold<double>(
          0, (s, v) => s + (v.purchaseCost ?? 0) + (v.operationExpenses ?? 0));

      VehicleProfitReportModel? mostProfitable;
      VehicleProfitReportModel? highestExpense;
      for (final v in soldList) {
        if (mostProfitable == null || v.profitLoss > mostProfitable.profitLoss) {
          mostProfitable = v;
        }
      }
      for (final v in vehicleProfits) {
        if (highestExpense == null ||
            (v.operationExpenses ?? 0) > (highestExpense.operationExpenses ?? 0)) {
          highestExpense = v;
        }
      }

      final summary = ReportSummaryModel(
        totalVehicles: vehicleProfits.length,
        soldVehicles: soldList.length,
        stockVehicles: stockList.length,
        totalRevenue: totalRevenue,
        totalPurchaseCost: totalPurchaseCost,
        totalOperationExpenses: totalOpExpenses,
        totalFinancingCost: totalFinancing,
        netProfit: netProfit,
        avgProfitPerSoldVehicle:
            soldList.isEmpty ? 0 : netProfit / soldList.length,
        stockInvestment: stockInvestment.toInt(),
        mostProfitableVehicle: mostProfitable?.vehicleName,
        highestExpenseVehicle: highestExpense?.vehicleName,
      );

      return ApiResult.success((
        summary: summary,
        vehicles: vehicleProfits,
        monthlyProfit: monthlyProfit,
        expenseDistribution: expenseDistribution,
      ));
    } catch (e) {
      return ApiResult.failure(const ApiException(
        type: ApiErrorType.parseError,
        message: 'Rapor verileri hesaplanamadı.',
      ));
    }
  }

  // ─── YARDIMCI ─────────────────────────────────────────
  bool _isInPeriod(DateTime? date, String period) {
    if (date == null) return period == 'Tümü';
    final now = DateTime.now();
    return switch (period) {
      'Bu Ay' => date.year == now.year && date.month == now.month,
      'Son 3 Ay' => date
          .isAfter(DateTime(now.year, now.month - 2, 1).subtract(const Duration(days: 1))),
      'Bu Yıl' => date.year == now.year,
      _ => true,
    };
  }

  String _monthKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';

  static const _monthNames = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  List<Map<String, String>> _buildMonthRange(String period) {
    final now = DateTime.now();
    final result = <Map<String, String>>[];
    switch (period) {
      case 'Bu Ay':
        result.add({
          'key': _monthKey(now),
          'label': _monthNames[now.month - 1],
        });
      case 'Son 3 Ay':
        for (int i = 2; i >= 0; i--) {
          final d = DateTime(now.year, now.month - i, 1);
          result.add({'key': _monthKey(d), 'label': _monthNames[d.month - 1]});
        }
      case 'Bu Yıl':
        for (int m = 1; m <= now.month; m++) {
          final d = DateTime(now.year, m);
          result.add({'key': _monthKey(d), 'label': _monthNames[m - 1]});
        }
      default: // Tümü - son 12 ay
        for (int i = 11; i >= 0; i--) {
          final d = DateTime(now.year, now.month - i, 1);
          result.add({'key': _monthKey(d), 'label': _monthNames[d.month - 1]});
        }
    }
    return result;
  }
}
