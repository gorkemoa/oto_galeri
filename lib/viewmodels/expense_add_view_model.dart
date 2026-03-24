import 'package:flutter/material.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/services/expense_service.dart';
import 'package:oto_galeri/services/vehicle_service.dart';
import 'package:oto_galeri/core/utils/logger.dart';

/// ExpenseAddViewModel - Masraf Ekle ekranı state yönetimi
class ExpenseAddViewModel extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  final VehicleService _vehicleService = VehicleService();

  // ─── STATE ────────────────────────────────────────────
  bool isLoading = false;
  bool isLoadingVehicles = false;
  String? errorMessage;
  bool isSaved = false;
  List<VehicleModel> vehicles = [];

  // ─── FORM STATE ───────────────────────────────────────
  VehicleModel? selectedVehicle;
  String selectedType = 'Servis';
  DateTime selectedDate = DateTime.now();

  // ─── CONTROLLERS ──────────────────────────────────────
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // ─── SEÇENEK LİSTELERİ ────────────────────────────────
  static const List<String> expenseTypes = [
    'Servis',
    'Tamir',
    'Lastik',
    'Yakıt',
    'Noter',
    'Temizlik',
    'Ekspertiz',
    'Diğer',
  ];

  // ─── INIT ─────────────────────────────────────────────
  Future<void> init() async {
    isLoadingVehicles = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _vehicleService.getVehicles();
      result.fold(
        onSuccess: (data) {
          vehicles = data;
        },
        onFailure: (error) {
          AppLogger.error('Araçlar yüklenemedi', error: error);
          errorMessage = error.userMessage;
        },
      );
    } catch (e) {
      AppLogger.error('ExpenseAddViewModel init hatası', error: e);
      errorMessage = 'Araçlar yüklenirken bir hata oluştu.';
    } finally {
      isLoadingVehicles = false;
      notifyListeners();
    }
  }

  // ─── REFRESH ──────────────────────────────────────────
  Future<void> refresh() async => init();

  // ─── LOAD MORE ────────────────────────────────────────
  Future<void> loadMore() async {}

  // ─── ON RETRY ─────────────────────────────────────────
  Future<void> onRetry() async => init();

  // ─── SETTERS ──────────────────────────────────────────
  void setVehicle(VehicleModel? vehicle) {
    selectedVehicle = vehicle;
    notifyListeners();
  }

  void setType(String type) {
    selectedType = type;
    notifyListeners();
  }

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  // ─── MASRAF EKLE ──────────────────────────────────────
  Future<bool> addExpense() async {
    if (selectedVehicle == null) return false;

    final raw = amountController.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = {
        'vehicle_id': selectedVehicle!.id,
        'vehicle_name': selectedVehicle!.fullName,
        'vehicle_brand': selectedVehicle!.brand,
        'vehicle_model': selectedVehicle!.model,
        'type': selectedType,
        'amount': amount,
        'date': selectedDate.toIso8601String(),
        'description': descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      };

      final result = await _expenseService.addExpense(data);
      return result.fold(
        onSuccess: (_) {
          isSaved = true;
          return true;
        },
        onFailure: (error) {
          AppLogger.error('Masraf eklenemedi', error: error);
          errorMessage = error.userMessage;
          return false;
        },
      );
    } catch (e) {
      AppLogger.error('addExpense hatası', error: e);
      errorMessage = 'Masraf eklenirken bir hata oluştu.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── RESET ────────────────────────────────────────────
  void reset() {
    selectedVehicle = null;
    selectedType = 'Servis';
    selectedDate = DateTime.now();
    amountController.clear();
    descriptionController.clear();
    errorMessage = null;
    isSaved = false;
    notifyListeners();
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
