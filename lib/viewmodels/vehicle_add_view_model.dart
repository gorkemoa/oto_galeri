import 'package:flutter/material.dart';
import 'package:oto_galeri/services/vehicle_service.dart';
import 'package:oto_galeri/core/utils/logger.dart';

/// VehicleAddViewModel - Araç Ekle ekranı state yönetimi
class VehicleAddViewModel extends ChangeNotifier {
  final VehicleService _service = VehicleService();

  // ─── STATE ────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;
  bool isSaved = false;

  // ─── FORM FIELDS ──────────────────────────────────────

  // Araç Bilgileri
  String? brand;
  String? model;
  int? year;
  int? kilometer;
  String? fuelType;
  String? color;
  String? plate;

  // Alış Bilgileri
  double? purchasePrice;
  DateTime? purchaseDate;
  String? paymentMethod;

  // Sigorta Bilgileri
  DateTime? insuranceDate;
  DateTime? kaskoDate;
  DateTime? inspectionDate;

  // ─── SEÇENEK LİSTELERİ ────────────────────────────────
  static const List<String> fuelTypes = ['Benzin', 'Dizel', 'LPG', 'Elektrik', 'Hibrit'];
  static const List<String> paymentMethods = ['Nakit', 'Çek', 'Vadeli'];

  // ─── FORM KONTROLCÜLER ────────────────────────────────
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController kilometerController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();

  // ─── SETTERS (Dropdown / DatePicker için) ─────────────
  void setFuelType(String? value) {
    fuelType = value;
    notifyListeners();
  }

  void setPaymentMethod(String? value) {
    paymentMethod = value;
    notifyListeners();
  }

  void setPurchaseDate(DateTime? date) {
    purchaseDate = date;
    notifyListeners();
  }

  void setInsuranceDate(DateTime? date) {
    insuranceDate = date;
    notifyListeners();
  }

  void setKaskoDate(DateTime? date) {
    kaskoDate = date;
    notifyListeners();
  }

  void setInspectionDate(DateTime? date) {
    inspectionDate = date;
    notifyListeners();
  }

  // ─── ARAÇ EKLE ────────────────────────────────────────
  Future<bool> addVehicle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{
        'brand': brandController.text.trim(),
        'model': modelController.text.trim(),
        'year': int.tryParse(yearController.text.trim()),
        'kilometer': int.tryParse(kilometerController.text.trim()),
        'fuel_type': fuelType,
        'color': colorController.text.trim().isEmpty ? null : colorController.text.trim(),
        'plate': plateController.text.trim().isEmpty ? null : plateController.text.trim(),
        'purchase_price': double.tryParse(
          purchasePriceController.text.trim().replaceAll('.', '').replaceAll(',', '.'),
        ),
        'purchase_date': purchaseDate?.toIso8601String().split('T').first,
        'payment_method': paymentMethod,
        'insurance_date': insuranceDate?.toIso8601String().split('T').first,
        'kasko_date': kaskoDate?.toIso8601String().split('T').first,
        'inspection_date': inspectionDate?.toIso8601String().split('T').first,
      };

      final result = await _service.addVehicle(data);

      bool success = false;
      result.fold(
        onSuccess: (_) {
          isSaved = true;
          success = true;
        },
        onFailure: (error) {
          AppLogger.error('Araç eklenemedi', error: error);
          errorMessage = error.userMessage;
        },
      );

      return success;
    } catch (e) {
      AppLogger.error('addVehicle hatası', error: e);
      errorMessage = 'Araç eklenirken bir hata oluştu.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── RESET ────────────────────────────────────────────
  void reset() {
    brandController.clear();
    modelController.clear();
    yearController.clear();
    kilometerController.clear();
    colorController.clear();
    plateController.clear();
    purchasePriceController.clear();
    fuelType = null;
    paymentMethod = null;
    purchaseDate = null;
    insuranceDate = null;
    kaskoDate = null;
    inspectionDate = null;
    isLoading = false;
    errorMessage = null;
    isSaved = false;
    notifyListeners();
  }

  @override
  void dispose() {
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    kilometerController.dispose();
    colorController.dispose();
    plateController.dispose();
    purchasePriceController.dispose();
    super.dispose();
  }
}
