/// AppConstants - Uygulama genel sabitleri
class AppConstants {
  AppConstants._();

  // ─── APP INFO ───────────────────────────────────────────
  static const String appName = 'Oto Galeri';
  static const String appVersion = '1.0.0';

  // ─── REFERENCE DEVICE (iPhone 13) ──────────────────────
  static const double referenceWidth = 390.0;
  static const double referenceHeight = 844.0;

  // ─── TIMEOUT ───────────────────────────────────────────
  static const int connectionTimeout = 30000; // 30 saniye
  static const int receiveTimeout = 30000; // 30 saniye

  // ─── PAGINATION ────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ─── DATE FORMATS ──────────────────────────────────────
  static const String dateFormat = 'dd MMMM yyyy';
  static const String dateFormatShort = 'dd.MM.yyyy';
  static const String dateTimeFormat = 'dd MMMM yyyy HH:mm';

  // ─── CURRENCY ──────────────────────────────────────────
  static const String currencySymbol = '₺';
  static const String currencyLocale = 'tr_TR';
}
