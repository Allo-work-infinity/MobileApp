import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_finding/modules/job_details/Repository/company_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentRepositoryHttp {
  final String baseUrl; // e.g. http://192.168.100.11:8000
  final http.Client _client;
  final Duration _timeout;
  static const _tokenKey = 'auth_token';

  /// Optional default headers that will always be included.
  final Map<String, String>? _defaultHeaders;

  /// Sync token getter (e.g. () => context.read<AuthController>().token)
  /// If your endpoint is public, pass `() => null`.
  final String? Function()? _tokenProvider;

  PaymentRepositoryHttp({
    required this.baseUrl,
    http.Client? client,
    String? Function()? tokenProvider,
    Map<String, String>? defaultHeaders,
    Duration timeout = const Duration(seconds: 20),
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider,
        _defaultHeaders = defaultHeaders,
        _timeout = timeout;

  /// Initialize payment on the backend (Laravel -> Konnect).
  /// - If you use hosted checkout, pass `token = null` (or empty) and your backend should set `checkoutForm: true`.
  /// - If you use client-side tokenization, pass the Konnect payment token here.
  Future<Map<String, dynamic>> initPayment({
    required int subscriptionPlanId,
    String? token,        // Konnect payment token (optional for hosted checkout)
    String? description,
  }) async {
    // If your route is in routes/api.php, keep /api. Otherwise remove it.
    final uri = Uri.parse('$baseUrl/api/payment/init-konnect');

    final headers = await _headers();

    final bodyMap = <String, dynamic>{
      'subscription_plan_id': subscriptionPlanId,
      if (description != null) 'description': description,
    };
    if (token != null && token.isNotEmpty) {
      bodyMap['token'] = token;
    }

    final res = await _client
        .post(uri, headers: headers, body: jsonEncode(bodyMap))
        .timeout(_timeout);

    final decoded = _safeJson(res.body);

    if (res.statusCode == 404) {
      throw const NotFoundException('Endpoint /api/payment/init-konnect not found.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Failed to init payment',
          statusCode: res.statusCode, payload: decoded);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Unexpected response format from initPayment');
    }
    return decoded;
  }

  /// Submit a manual payment (bank transfer or D17) with proof image.
  ///
  /// Server route (in routes/api.php):
  ///   Route::post('/payment/manual', [PaymentApiController::class, 'apiStoreManual']);
  ///
  /// Required:
  /// - [amount] : total amount
  /// - [method] : 'bank_transfer' or 'd17'
  /// - [proofPath] : local file path to the image
  ///
  /// Optional:
  /// - [currency] : default 'TND'
  /// - [subscriptionId], [manualReference], [note]
  Future<Map<String, dynamic>> submitManualPayment({
    required double amount,
    required String method,        // 'bank_transfer' | 'd17'
    required String proofPath,     // e.g. from XFile.path
    String currency = 'TND',
    int? subscriptionId,
    String? manualReference,
    String? note,
  }) async {
    // If your route is in routes/api.php, keep /api. Otherwise remove it.
    final uri = Uri.parse('$baseUrl/api/payment/manual');

    final headers = await _headersForMultipart();

    final req = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields['amount'] = amount.toStringAsFixed(2)
      ..fields['method'] = method
      ..fields['currency'] = currency.toUpperCase();

    if (subscriptionId != null) {
      req.fields['subscription_id'] = subscriptionId.toString();
    }
    if (manualReference != null && manualReference.isNotEmpty) {
      req.fields['manual_reference'] = manualReference;
    }
    if (note != null && note.isNotEmpty) {
      req.fields['note'] = note;
    }

    req.files.add(await http.MultipartFile.fromPath('proof', proofPath));

    final streamed = await req.send().timeout(_timeout);
    final res = await http.Response.fromStream(streamed);
    final decoded = _safeJson(res.body);

    if (res.statusCode == 404) {
      throw const NotFoundException('Endpoint /api/payment/manual not found.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Failed to submit manual payment',
          statusCode: res.statusCode, payload: decoded);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Unexpected response format from submitManualPayment');
    }
    return decoded;
  }

  // -------------------- Internals --------------------

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
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

  /// Headers for multipart requests:
  /// - Do NOT set Content-Type here; http.MultipartRequest sets it with boundary.
  Future<Map<String, String>> _headersForMultipart() async {
    final token = await _getToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      if (_defaultHeaders != null) ..._defaultHeaders!,
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String?> _getToken() async {
    // Prefer a live provider (if supplied), else fallback to SharedPreferences
    if (_tokenProvider != null) {
      final t = _tokenProvider!.call();
      if (t != null && t.isNotEmpty) return t;
    }
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey);
  }

  dynamic _safeJson(String source) {
    try {
      return jsonDecode(source);
    } catch (_) {
      return source;
    }
  }
}
