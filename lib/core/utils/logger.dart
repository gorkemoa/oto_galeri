import 'dart:developer' as dev;

/// AppLogger - Uygulama loglama standardı
/// print kullanımı YASAKTIR. Tüm loglar bu sınıf üzerinden yapılır.
class AppLogger {
  AppLogger._();

  static const String _tag = 'OtoGaleri';

  /// Bilgi logu
  static void info(String message) {
    _log('INFO', message);
  }

  /// Hata logu
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message);
    if (error != null) {
      _log('ERROR', 'Error: $error');
    }
    if (stackTrace != null) {
      _log('ERROR', 'StackTrace: $stackTrace');
    }
  }

  /// Uyarı logu
  static void warning(String message) {
    _log('WARNING', message);
  }

  /// Debug logu
  static void debug(String message) {
    _log('DEBUG', message);
  }

  /// HTTP Request logu
  static void request(String method, String url, {Map<String, dynamic>? body}) {
    _log('REQUEST', '[$method] $url');
    if (body != null) {
      _log('REQUEST', 'Body: $body');
    }
  }

  /// HTTP Response logu
  static void response(int statusCode, String body) {
    final truncatedBody = body.length > 500 ? '${body.substring(0, 500)}...' : body;
    _log('RESPONSE', '[$statusCode] $truncatedBody');
  }

  /// Ana log metodu
  static void _log(String level, String message) {
    dev.log(
      '[$level] $message',
      name: _tag,
      time: DateTime.now(),
    );
  }
}
