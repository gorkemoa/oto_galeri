import 'package:flutter/material.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/models/expense_model.dart';
import 'package:oto_galeri/services/vehicle_service.dart';
import 'package:oto_galeri/services/expense_service.dart';
import 'package:oto_galeri/core/utils/logger.dart';

/// VehicleDetailViewModel - Araç detay ekranı state yönetimi
class VehicleDetailViewModel extends ChangeNotifier {
  final VehicleService _vehicleService = VehicleService();
  final ExpenseService _expenseService = ExpenseService();

  // ─── STATE ────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;
  VehicleModel? vehicle;
  List<ExpenseModel>? expenses;

  final int vehicleId;

  VehicleDetailViewModel({required this.vehicleId});

  // ─── INIT ─────────────────────────────────────────────
  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _vehicleService.getVehicleDetail(vehicleId),
        _expenseService.getExpenses(vehicleId: vehicleId),
      ]);

      results[0].fold(
        onSuccess: (data) => vehicle = data as VehicleModel,
        onFailure: (error) {
          AppLogger.error('Araç detay yüklenemedi', error: error);
          errorMessage = error.userMessage;
        },
      );

      results[1].fold(
        onSuccess: (data) => expenses = data as List<ExpenseModel>,
        onFailure: (error) {
          AppLogger.error('Araç giderleri yüklenemedi', error: error);
          errorMessage ??= error.userMessage;
        },
      );
    } catch (e) {
      AppLogger.error('Araç detay init hatası', error: e);
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

  // ─── GİDER EKLE ──────────────────────────────────────
  Future<bool> addExpense({
    required String type,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    try {
      final result = await _expenseService.addExpense({
        'vehicle_id': vehicleId,
        'vehicle_name': vehicle?.fullName,
        'vehicle_brand': vehicle?.brand,
        'vehicle_model': vehicle?.model,
        'type': type,
        'amount': amount,
        'date': date.toIso8601String(),
        'description': description,
      });

      return result.fold(
        onSuccess: (newExpense) {
          expenses = [newExpense, ...(expenses ?? [])];
          expenses!.sort((a, b) =>
              (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
          notifyListeners();
          return true;
        },
        onFailure: (error) {
          AppLogger.error('Gider eklenemedi', error: error);
          return false;
        },
      );
    } catch (e) {
      AppLogger.error('addExpense hatası', error: e);
      return false;
    }
  }

  // ─── RETRY ────────────────────────────────────────────
  Future<void> onRetry() async {
    await init();
  }
}
