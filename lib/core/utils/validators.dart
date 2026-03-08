/// Validators - Form doğrulama kuralları
class Validators {
  Validators._();

  /// Boş kontrolü
  static String? required(String? value, {String fieldName = 'Bu alan'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz.';
    }
    return null;
  }

  /// Sayısal değer kontrolü
  static String? numeric(String? value, {String fieldName = 'Bu alan'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz.';
    }
    final cleaned = value.replaceAll('.', '').replaceAll(',', '').replaceAll(' ', '');
    if (double.tryParse(cleaned) == null) {
      return '$fieldName geçerli bir sayı olmalıdır.';
    }
    return null;
  }

  /// Pozitif sayı kontrolü
  static String? positiveNumber(String? value, {String fieldName = 'Bu alan'}) {
    final numericError = numeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;

    final cleaned = value!.replaceAll('.', '').replaceAll(',', '').replaceAll(' ', '');
    final number = double.parse(cleaned);
    if (number <= 0) {
      return '$fieldName sıfırdan büyük olmalıdır.';
    }
    return null;
  }

  /// Telefon numarası kontrolü
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numarası boş bırakılamaz.';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 10 || cleaned.length > 13) {
      return 'Geçerli bir telefon numarası giriniz.';
    }
    return null;
  }

  /// Plaka kontrolü
  static String? plate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Plaka boş bırakılamaz.';
    }
    // Basit Türkiye plaka formatı kontrolü
    final cleaned = value.replaceAll(' ', '').toUpperCase();
    if (cleaned.length < 7 || cleaned.length > 8) {
      return 'Geçerli bir plaka giriniz.';
    }
    return null;
  }

  /// Yıl kontrolü
  static String? year(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Yıl boş bırakılamaz.';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Geçerli bir yıl giriniz.';
    }
    final currentYear = DateTime.now().year;
    if (year < 1950 || year > currentYear + 1) {
      return 'Yıl 1950 ile ${currentYear + 1} arasında olmalıdır.';
    }
    return null;
  }

  /// KM kontrolü
  static String? kilometer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'KM boş bırakılamaz.';
    }
    final cleaned = value.replaceAll('.', '').replaceAll(',', '').replaceAll(' ', '');
    final km = int.tryParse(cleaned);
    if (km == null || km < 0) {
      return 'Geçerli bir kilometre giriniz.';
    }
    if (km > 2000000) {
      return 'KM değeri çok yüksek.';
    }
    return null;
  }
}
