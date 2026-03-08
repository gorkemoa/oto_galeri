/// ApiResult - Service dönüş tipi
/// Success(data) veya Failure(error) döner.
sealed class ApiResult<T> {
  const ApiResult();

  /// Başarılı sonuç
  factory ApiResult.success(T data) = ApiSuccess<T>;

  /// Hatalı sonuç
  factory ApiResult.failure(ApiException error) = ApiFailure<T>;

  /// Fold pattern - her iki durumu handle et
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(ApiException error) onFailure,
  }) {
    return switch (this) {
      ApiSuccess<T>(data: final data) => onSuccess(data),
      ApiFailure<T>(error: final error) => onFailure(error),
    };
  }

  /// Başarılı mı?
  bool get isSuccess => this is ApiSuccess<T>;

  /// Başarısız mı?
  bool get isFailure => this is ApiFailure<T>;
}

/// Başarılı sonuç
class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

/// Hatalı sonuç
class ApiFailure<T> extends ApiResult<T> {
  final ApiException error;
  const ApiFailure(this.error);
}

/// ApiException - Normalize edilmiş hata tipleri
class ApiException implements Exception {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? validationErrors;

  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.validationErrors,
  });

  /// Validation hatalarını tek string olarak döndür
  String get validationMessage {
    if (validationErrors == null || validationErrors!.isEmpty) {
      return message;
    }
    final messages = <String>[];
    for (final entry in validationErrors!.entries) {
      messages.addAll(entry.value);
    }
    return messages.join('\n');
  }

  /// Kullanıcıya gösterilecek mesaj
  String get userMessage {
    if (validationErrors != null && validationErrors!.isNotEmpty) {
      return validationMessage;
    }
    return switch (type) {
      ApiErrorType.network => 'İnternet bağlantınızı kontrol edin.',
      ApiErrorType.timeout => 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.',
      ApiErrorType.unauthorized => 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.',
      ApiErrorType.forbidden => 'Bu işlem için yetkiniz bulunmuyor.',
      ApiErrorType.notFound => 'Aradığınız kaynak bulunamadı.',
      ApiErrorType.server => 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.',
      ApiErrorType.parseError => 'Veri işleme hatası oluştu.',
      ApiErrorType.unknown => message.isNotEmpty ? message : 'Bilinmeyen bir hata oluştu.',
      ApiErrorType.validation => validationMessage,
    };
  }

  @override
  String toString() => 'ApiException(type: $type, message: $message, statusCode: $statusCode)';
}

/// Hata tipleri
enum ApiErrorType {
  network,
  timeout,
  unauthorized, // 401
  forbidden, // 403
  notFound, // 404
  server, // 500
  parseError,
  validation,
  unknown,
}
