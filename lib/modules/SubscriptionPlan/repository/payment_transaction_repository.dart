import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_finding/modules/job_details/Repository/company_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_finding/modules/SubscriptionPlan/model/payment_transaction.dart';

class PaymentTransactionRepositoryHttp {
  final String baseUrl; // e.g. http://192.168.100.11:8000
  final http.Client _client;
  final Duration _timeout;

  /// Optional default headers that will always be included.
  final Map<String, String>? _defaultHeaders;

  /// Optional sync token getter (e.g. () => context.read<AuthController>().token).
  /// If provided, it takes precedence over SharedPreferences.
  final String? Function()? _tokenProvider;

  static const _tokenKey = 'auth_token';

  PaymentTransactionRepositoryHttp({
    required this.baseUrl,
    http.Client? client,
    String? Function()? tokenProvider,
    Map<String, String>? defaultHeaders,
    Duration timeout = const Duration(seconds: 20),
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider,
        _defaultHeaders = defaultHeaders,
        _timeout = timeout;

  /// Create a PaymentTransaction (save payment).
  ///
  /// Usually set:
  /// - subscription_id
  /// - konnect_payment_id
  /// - status (pending by default on backend is fine)
  /// - konnect_response (optional)
  Future<PaymentTransaction> create({
    required int subscriptionId,
    required String konnectPaymentId,
    String? konnectTransactionId,
    double? amount, // if backend derives it, omit
    String currency = 'TND',
    String? paymentMethod,
    PaymentStatus status = PaymentStatus.pending,
    Map<String, dynamic>? konnectResponse,
    String? failureReason,
    DateTime? processedAt,
  }) async {
    final uri = Uri.parse('$baseUrl/api/payment-transactions');
    final headers = await _headers();

    final payload = <String, dynamic>{
      'subscription_id': subscriptionId,
      'konnect_payment_id': konnectPaymentId,
      if (konnectTransactionId != null)
        'konnect_transaction_id': konnectTransactionId,
      if (amount != null) 'amount': _toFixed(amount, 3),
      'currency': currency,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      'status': status.value,
      if (konnectResponse != null) 'konnect_response': konnectResponse,
      if (failureReason != null) 'failure_reason': failureReason,
      if (processedAt != null) 'processed_at': processedAt.toUtc().toIso8601String(),
    };

    final res = await _client
        .post(uri, headers: headers, body: jsonEncode(payload))
        .timeout(_timeout);

    final decoded = _safeJson(res.body);

    if (res.statusCode == 404) {
      throw const NotFoundException('Endpoint /api/payment-transactions not found.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(_errorMessage('Failed to create PaymentTransaction', decoded),
          statusCode: res.statusCode, payload: decoded);
    }

    if (decoded is Map<String, dynamic>) {
      final map = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;
      return PaymentTransaction.fromJson(map);
    }

    throw const ApiException('Unexpected response format when creating PaymentTransaction');
  }
  Future<Map<String, dynamic>> submitManualPayment({
    required double amount,
    required String method,      // 'bank_transfer' | 'd17'
    required String proofPath,   // local file path to the image
    String currency = 'TND',
    int? subscriptionId,
    String? manualReference,
    String? note,
  }) async {
    final uri = Uri.parse('$baseUrl/api/payment/manual');

    // IMPORTANT: do NOT set Content-Type here; MultipartRequest will handle it.
    final headers = await _authHeadersForMultipart();

    final req = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields['amount'] = _toFixed(amount, 3)
      ..fields['method'] = method
      ..fields['currency'] = currency;

    if (subscriptionId != null) {
      req.fields['subscription_id'] = subscriptionId.toString();
    }
    if (manualReference != null && manualReference.isNotEmpty) {
      req.fields['manual_reference'] = manualReference;
    }
    if (note != null && note.isNotEmpty) {
      req.fields['note'] = note;
    }

    // Attach the image file
    req.files.add(await http.MultipartFile.fromPath('proof', proofPath));

    // Send + convert to a normal Response (so we can read status/body easily)
    final streamed = await req.send().timeout(_timeout);
    final res = await http.Response.fromStream(streamed);

    final decoded = _safeJson(res.body);

    if (res.statusCode == 404) {
      throw const NotFoundException('Endpoint /api/payment/manual not found.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        _errorMessage('Failed to submit manual payment', decoded),
        statusCode: res.statusCode,
        payload: decoded,
      );
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const ApiException('Unexpected response format from /api/payment/manual');
  }

  /// Authorization headers for multipart/form-data (no explicit Content-Type).
  Future<Map<String, String>> _authHeadersForMultipart() async {
    final token = _tokenProvider?.call() ?? await _getTokenFromPrefs();
    final headers = <String, String>{
      'Accept': 'application/json',
      if (_defaultHeaders != null) ..._defaultHeaders!,
    };
    // Ensure we don't send a fixed Content-Type that would break multipart.
    headers.removeWhere((k, _) => k.toLowerCase() == 'content-type');

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
  /// Update a transaction by ID (e.g., after success/failure).
  Future<PaymentTransaction> update({
    required int id,
    PaymentStatus? status,
    String? konnectTransactionId,
    Map<String, dynamic>? konnectResponse,
    String? failureReason,
    DateTime? processedAt,
  }) async {
    final uri = Uri.parse('$baseUrl/api/payment-transactions/$id');
    final headers = await _headers();

    final payload = <String, dynamic>{
      if (status != null) 'status': status.value,
      if (konnectTransactionId != null)
        'konnect_transaction_id': konnectTransactionId,
      if (konnectResponse != null) 'konnect_response': konnectResponse,
      if (failureReason != null) 'failure_reason': failureReason,
      if (processedAt != null) 'processed_at': processedAt.toUtc().toIso8601String(),
    };

    final res = await _client
        .put(uri, headers: headers, body: jsonEncode(payload))
        .timeout(_timeout);

    final decoded = _safeJson(res.body);

    if (res.statusCode == 404) {
      throw NotFoundException('PaymentTransaction $id not found.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(_errorMessage('Failed to update PaymentTransaction', decoded),
          statusCode: res.statusCode, payload: decoded);
    }

    if (decoded is Map<String, dynamic>) {
      final map = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;
      return PaymentTransaction.fromJson(map);
    }

    throw const ApiException('Unexpected response format when updating PaymentTransaction');
  }

  /// Fetch by ID.
  Future<PaymentTransaction> getById(int id) async {
    final uri = Uri.parse('$baseUrl/api/payment-transactions/$id');
    final headers = await _headers();

    final res = await _client.get(uri, headers: headers).timeout(_timeout);
    final decoded = _safeJson(res.body);

    if (res.statusCode == 404) {
      throw NotFoundException('PaymentTransaction $id not found.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(_errorMessage('Failed to fetch PaymentTransaction', decoded),
          statusCode: res.statusCode, payload: decoded);
    }

    if (decoded is Map<String, dynamic>) {
      final map = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;
      return PaymentTransaction.fromJson(map);
    }

    throw const ApiException('Unexpected response format when fetching PaymentTransaction');
  }

  // -------------------- internals --------------------

  Future<Map<String, String>> _headers() async {
    // Prefer provider token if available; fall back to SharedPreferences
    final token = _tokenProvider?.call() ?? await _getTokenFromPrefs();

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (_defaultHeaders != null) ..._defaultHeaders!,
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String?> _getTokenFromPrefs() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey);
    // If you keep your token under a different key, adjust _tokenKey.
  }

  dynamic _safeJson(String source) {
    try {
      return jsonDecode(source);
    } catch (_) {
      return source;
    }
  }

  String _errorMessage(String fallback, dynamic decoded) {
    if (decoded is Map && decoded['message'] != null) {
      var msg = decoded['message'].toString();
      if (decoded['errors'] is Map) {
        final errs = (decoded['errors'] as Map)
            .values
            .expand((e) => e is List ? e : [e])
            .join('; ');
        if (errs.isNotEmpty) msg = '$msg: $errs';
      }
      return msg;
    }
    return fallback;
  }

  String _toFixed(double v, int f) => v.toStringAsFixed(f);
}
