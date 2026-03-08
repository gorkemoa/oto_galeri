import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:oto_galeri/app/api_constants.dart';
import 'package:oto_galeri/app/app_constants.dart';
import 'package:oto_galeri/core/network/api_result.dart';
import 'package:oto_galeri/core/utils/logger.dart';

/// ApiClient - Tek noktadan HTTP yönetimi
/// baseUrl, ortak header, timeout, error handling, logging
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  String? _authToken;

  // ─── HEADERS ──────────────────────────────────────────
  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// Auth token set et
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Auth token temizle
  void clearAuthToken() {
    _authToken = null;
  }

  // ─── GET ──────────────────────────────────────────────
  Future<ApiResult<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    AppLogger.request('GET', uri.toString());

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(Duration(milliseconds: AppConstants.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      return ApiResult.failure(_handleError(e));
    }
  }

  // ─── POST ─────────────────────────────────────────────
  Future<ApiResult<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);
    AppLogger.request('POST', uri.toString(), body: body);

    try {
      final response = await _client
          .post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(Duration(milliseconds: AppConstants.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      return ApiResult.failure(_handleError(e));
    }
  }

  // ─── PUT ──────────────────────────────────────────────
  Future<ApiResult<Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);
    AppLogger.request('PUT', uri.toString(), body: body);

    try {
      final response = await _client
          .put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(Duration(milliseconds: AppConstants.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      return ApiResult.failure(_handleError(e));
    }
  }

  // ─── DELETE ───────────────────────────────────────────
  Future<ApiResult<Map<String, dynamic>>> delete(
    String endpoint,
  ) async {
    final uri = _buildUri(endpoint);
    AppLogger.request('DELETE', uri.toString());

    try {
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(Duration(milliseconds: AppConstants.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      return ApiResult.failure(_handleError(e));
    }
  }

  // ─── URI BUILDER ──────────────────────────────────────
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }

  // ─── RESPONSE HANDLER ────────────────────────────────
  ApiResult<Map<String, dynamic>> _handleResponse(http.Response response) {
    AppLogger.response(response.statusCode, response.body);

    try {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.success(data);
      }

      // Validation errors (422)
      if (response.statusCode == 422 || response.statusCode == 400) {
        Map<String, List<String>>? validationErrors;
        if (data.containsKey('errors') && data['errors'] is Map) {
          final errorsMap = data['errors'] as Map<String, dynamic>;
          validationErrors = errorsMap.map(
            (key, value) => MapEntry(
              key,
              (value as List).map((e) => e.toString()).toList(),
            ),
          );
        }
        return ApiResult.failure(ApiException(
          type: ApiErrorType.validation,
          message: data['message']?.toString() ?? 'Doğrulama hatası',
          statusCode: response.statusCode,
          validationErrors: validationErrors,
        ));
      }

      return ApiResult.failure(_mapStatusCode(response.statusCode, data));
    } catch (e) {
      return ApiResult.failure(const ApiException(
        type: ApiErrorType.parseError,
        message: 'Sunucu yanıtı işlenemedi.',
      ));
    }
  }

  // ─── STATUS CODE MAPPER ───────────────────────────────
  ApiException _mapStatusCode(int statusCode, Map<String, dynamic>? data) {
    final message = data?['message']?.toString() ?? '';
    return switch (statusCode) {
      401 => ApiException(type: ApiErrorType.unauthorized, message: message, statusCode: 401),
      403 => ApiException(type: ApiErrorType.forbidden, message: message, statusCode: 403),
      404 => ApiException(type: ApiErrorType.notFound, message: message, statusCode: 404),
      >= 500 => ApiException(type: ApiErrorType.server, message: message, statusCode: statusCode),
      _ => ApiException(type: ApiErrorType.unknown, message: message, statusCode: statusCode),
    };
  }

  // ─── ERROR HANDLER ────────────────────────────────────
  ApiException _handleError(Object error) {
    AppLogger.error('API Error', error: error);

    if (error is TimeoutException) {
      return const ApiException(type: ApiErrorType.timeout, message: 'İstek zaman aşımına uğradı.');
    }
    if (error is SocketException) {
      return const ApiException(type: ApiErrorType.network, message: 'İnternet bağlantısı yok.');
    }
    if (error is FormatException) {
      return const ApiException(type: ApiErrorType.parseError, message: 'Veri parse hatası.');
    }
    return ApiException(type: ApiErrorType.unknown, message: error.toString());
  }

  /// Client kapat
  void dispose() {
    _client.close();
  }
}
