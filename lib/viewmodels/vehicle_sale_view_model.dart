import 'package:flutter/material.dart';
import 'package:oto_galeri/models/vehicle_model.dart';
import 'package:oto_galeri/services/vehicle_service.dart';
import 'package:oto_galeri/core/utils/logger.dart';

/// VehicleSaleViewModel - Araç Sat ekranı state yönetimi
class VehicleSaleViewModel extends ChangeNotifier {
  final VehicleService _vehicleService = VehicleService();

  // ─── STATE ────────────────────────────────────────────
  bool isLoading = false;
  bool isLoadingVehicles = false;
  String? errorMessage;
  bool isSaved = false;
  List<VehicleModel> vehicles = [];

  // ─── FORM STATE ───────────────────────────────────────
  VehicleModel? selectedVehicle;
  String selectedPaymentMethod = 'Nakit';
  DateTime selectedDate = DateTime.now();

  // ─── CONTROLLERS ──────────────────────────────────────
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController customerBalanceController = TextEditingController();
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController installmentCountController = TextEditingController();

  // ─── SEÇENEK LİSTELERİ ────────────────────────────────
  static const List<String> paymentMethods = ['Nakit', 'Çek', 'Vadeli', 'Vadesiz'];

  // ─── HESAPLAMALAR ─────────────────────────────────────

  double? get salePrice {
    final raw = salePriceController.text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(raw);
  }

  double? get totalCost {
    if (selectedVehicle == null) return null;
    return (selectedVehicle!.purchasePrice ?? 0) + (selectedVehicle!.totalExpense ?? 0);
  }

  double? get profitLoss {
    final price = salePrice;
    final cost = totalCost;
    if (price == null || cost == null) return null;
    return price - cost;
  }

  bool get isVadeli => selectedPaymentMethod == 'Vadeli';

  double? get calculatedFinanceCharge {
    if (!isVadeli) return null;
    final rate = double.tryParse(interestRateController.text.replaceAll(',', '.'));
    final months = int.tryParse(installmentCountController.text);
    final price = salePrice;
    if (rate == null || months == null || price == null) return null;
    return price * (rate / 100) * months;
  }

  // ─── INIT ─────────────────────────────────────────────
  Future<void> init() async {
    isLoadingVehicles = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _vehicleService.getVehicles(status: 'STOKTA');
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
      AppLogger.error('VehicleSaleViewModel init hatası', error: e);
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

  void setPaymentMethod(String method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void notifyFieldChanged() {
    notifyListeners();
  }

  // ─── ARAÇ SAT ─────────────────────────────────────────
  Future<bool> sellVehicle() async {
    if (selectedVehicle?.id == null) return false;
    final price = salePrice;
    if (price == null || price <= 0) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = {
        'sale_price': price,
        'sale_date': selectedDate.toIso8601String(),
        'sale_payment_method': selectedPaymentMethod,
        'customer_name': customerNameController.text.trim().isEmpty
            ? null
            : customerNameController.text.trim(),
        'customer_phone': customerPhoneController.text.trim().isEmpty
            ? null
            : customerPhoneController.text.trim(),
        'customer_balance': double.tryParse(
          customerBalanceController.text.replaceAll('.', '').replaceAll(',', '.'),
        ),
        if (isVadeli)
          'interest_rate': double.tryParse(
            interestRateController.text.replaceAll(',', '.'),
          ),
        if (isVadeli) 'installment_count': int.tryParse(installmentCountController.text),
        if (isVadeli && calculatedFinanceCharge != null)
          'finance_charge_amount': calculatedFinanceCharge,
      };

      final result = await _vehicleService.sellVehicle(selectedVehicle!.id!, data);
      return result.fold(
        onSuccess: (_) {
          isSaved = true;
          return true;
        },
        onFailure: (error) {
          AppLogger.error('Araç satılamadı', error: error);
          errorMessage = error.userMessage;
          return false;
        },
      );
    } catch (e) {
      AppLogger.error('sellVehicle hatası', error: e);
      errorMessage = 'Araç satışı sırasında bir hata oluştu.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── RESET ────────────────────────────────────────────
  void reset() {
    selectedVehicle = null;
    selectedPaymentMethod = 'Nakit';
    selectedDate = DateTime.now();
    salePriceController.clear();
    customerNameController.clear();
    customerPhoneController.clear();
    customerBalanceController.clear();
    interestRateController.clear();
    installmentCountController.clear();
    errorMessage = null;
    isSaved = false;
    notifyListeners();
  }

  @override
  void dispose() {
    salePriceController.dispose();
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerBalanceController.dispose();
    interestRateController.dispose();
    installmentCountController.dispose();
    super.dispose();
  }
}
