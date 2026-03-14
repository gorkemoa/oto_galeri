import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:oto_galeri/services/vehicle_service.dart';
import 'package:oto_galeri/core/utils/logger.dart';

/// VehicleAddViewModel - Araç Ekle ekranı state yönetimi
class VehicleAddViewModel extends ChangeNotifier {
  final VehicleService _service = VehicleService();

  // ─── STATE ────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;
  bool isSaved = false;

  // Seçilen görsel yerel yolu (API hazır olduğunda upload edilecek)
  String? selectedImagePath;

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

  // DEMO: Vade farkı hesabı – backend hazır olduğunda servis/API katmanına taşınacak
  double? financeChargeAmount;

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

  // DEMO: Vade farkı hesabı kontrolcüleri – API hazır olduğunda servis/API katmanına taşınacak
  final TextEditingController interestRateController = TextEditingController();
  final TextEditingController installmentCountController = TextEditingController();

  // ─── SETTERS (Dropdown / DatePicker için) ─────────────
  void setFuelType(String? value) {
    fuelType = value;
    notifyListeners();
  }

  void setPaymentMethod(String? value) {
    paymentMethod = value;
    if (value == 'Nakit') {
      interestRateController.clear();
      installmentCountController.clear();
      financeChargeAmount = null;
    } else {
      calculateFinanceCharge();
    }
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

  // DEMO: Lokal vade farkı hesabı – backend hazır olduğunda bu hesap servis/API tarafına taşınacak
  void calculateFinanceCharge() {
    final price = double.tryParse(
      purchasePriceController.text.trim().replaceAll('.', '').replaceAll(',', '.'),
    );
    final rate = double.tryParse(
      interestRateController.text.trim().replaceAll(',', '.'),
    );

    if (price == null || rate == null || paymentMethod == null || paymentMethod == 'Nakit') {
      financeChargeAmount = null;
      notifyListeners();
      return;
    }

    if (paymentMethod == 'Çek') {
      financeChargeAmount = price * (rate / 100);
    } else if (paymentMethod == 'Vadeli') {
      final months = int.tryParse(installmentCountController.text.trim());
      financeChargeAmount = (months != null && months > 0)
          ? price * (rate / 100) * months
          : null;
    } else {
      financeChargeAmount = null;
    }
    notifyListeners();
  }

  // ─── GÖRSEL SEÇ ─────────────────────────────────────────
  Future<void> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        selectedImagePath = result.files.single.path;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Görsel seçilemedi', error: e);
    }
  }

  void removeImage() {
    selectedImagePath = null;
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
        // DEMO: Vade farkı hesabı – API hazır olduğunda backend alanlarıyla eşleşecek
        if (financeChargeAmount != null) ...{
          'interest_rate': double.tryParse(
            interestRateController.text.trim().replaceAll(',', '.'),
          ),
          'installment_count': paymentMethod == 'Vadeli'
              ? int.tryParse(installmentCountController.text.trim())
              : null,
          'finance_charge_amount': financeChargeAmount,
        },
        // TODO: API hazır olduğunda image upload entegre edilecek
        // 'image_path': selectedImagePath,
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
    selectedImagePath = null;
    // DEMO: Vade farkı hesabı – API hazır olduğunda temizlenecek
    interestRateController.clear();
    installmentCountController.clear();
    financeChargeAmount = null;
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
    interestRateController.dispose();
    installmentCountController.dispose();
    super.dispose();
  }
}
