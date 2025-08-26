// lib/modules/auth/repository/auth_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

/// -------- Exceptions (exported from this file so other layers can catch them) -----
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic payload;
  const ApiException(this.message, {this.statusCode, this.payload});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class AuthException extends ApiException {
  const AuthException(String message, {int? statusCode, dynamic payload})
      : super(message, statusCode: statusCode, payload: payload);
}

class CooldownException extends ApiException {
  final int? retryAfterSeconds;
  final DateTime? retryAt;
  const CooldownException(
      String message, {
        int? statusCode,
        dynamic payload,
        this.retryAfterSeconds,
        this.retryAt,
      }) : super(message, statusCode: statusCode, payload: payload);
}

/// -------- Repository --------------------------------------------------------------
class AuthRepository {
  static const _tokenKey = 'auth_token';
  final String baseUrl; // e.g. http://192.168.1.10:8000
  final http.Client _client;

  AuthRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // ---------- Public API ----------

  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? city,
    String? governorate,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/register');
    final res = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
        'city': city,
        'governorate': governorate,
      }),
    );

    final data = _decode(res);
    _throwIfNotOk(res, data);

    final token = (data['access_token'] ?? data['token']) as String?;
    if (token != null) {
      await _saveToken(token);
    }
    return User.fromJson((data['user'] as Map?)?.cast<String, dynamic>() ?? {});
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    final res = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _decode(res);
    _throwIfNotOk(res, data);

    // Save token if present (support both keys)
    final token = (data['access_token'] ?? data['token']) as String?;
    if (token != null) {
      await _saveToken(token);
    }

    // Merge top-level subscription fields into user json
    final userJson = Map<String, dynamic>.from(
      (data['user'] as Map?)?.cast<String, dynamic>() ?? {},
    )
      ..['has_active_subscription'] = data['has_active_subscription']
      ..['subscription'] = data['subscription'];

    return User.fromJson(userJson);
  }

  /// IMPORTANT: call **/api/auth/me** (NOT /api/users/me) so it's not blocked by usage.window.
  /// Returns User on success, null if unauthenticated (401).
  /// Throws [CooldownException] on 429 cooldown, keeping the local token intact.
  Future<User?> me() async {
    final token = await _getToken();
    if (token == null) return null;

    final uri = Uri.parse('$baseUrl/api/users/me');
    final res = await _client.get(uri, headers: _headers(authToken: token));

    if (res.statusCode == 200) {
      final data = _decode(res);

      // Merge top-level subscription fields into user json if present
      final userJson = Map<String, dynamic>.from(
        (data['user'] as Map?)?.cast<String, dynamic>() ?? data.cast<String, dynamic>(),
      )
        ..['has_active_subscription'] =
        data.containsKey('has_active_subscription') ? data['has_active_subscription'] : null
        ..['subscription'] =
        data.containsKey('subscription') ? data['subscription'] : null;

      return User.fromJson(userJson);
    }

    if (res.statusCode == 429) {
      final body = _decode(res);
      throw CooldownException(
        (body['message'] ?? 'Cooldown actif.').toString(),
        statusCode: 429,
        payload: body,
        retryAfterSeconds: (body['retry_after_seconds'] is num)
            ? (body['retry_after_seconds'] as num).toInt()
            : null,
        retryAt: DateTime.tryParse((body['retry_at'] ?? '').toString()),
      );
    }

    if (res.statusCode == 401) {
      // Token invalid/expired → clear and return null
      await logout(localOnly: true);
      return null;
    }

    final body = _decode(res);
    throw ApiException(
      (body['message'] ?? 'Request failed (${res.statusCode})').toString(),
      statusCode: res.statusCode,
      payload: body,
    );
  }

  //
  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? location,
    // Optional direct fields if you prefer sending them explicitly
    String? firstName,
    String? lastName,
    String? address,
    String? city,
    String? governorate,
    String? password, // optional; if provided, backend will hash
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw const AuthException('Unauthenticated', statusCode: 401);
    }

    // Build payload and strip null/empty values
    final Map<String, dynamic> payload = _compact({
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (location != null) 'location': location,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (governorate != null) 'governorate': governorate,
      if (password != null) 'password': password,
    });

    final uri = Uri.parse('$baseUrl/api/users'); // Route::patch('users', ...)
    final res = await _client.patch(
      uri,
      headers: _headers(authToken: token),
      body: jsonEncode(payload),
    );

    final data = _decode(res);

    if (res.statusCode == 200) {
      // some APIs return { user: {...} }, others return the user object directly
      final userJson = Map<String, dynamic>.from(
        (data['user'] as Map?)?.cast<String, dynamic>() ?? data.cast<String, dynamic>(),
      );
      return User.fromJson(userJson);
    }

    if (res.statusCode == 401) {
      await logout(localOnly: true);
      throw const AuthException('Unauthenticated', statusCode: 401);
    }

    // Bubble up message/details the same way as other methods
    final msg = (data['message'] ?? data['errors']?.toString() ?? 'Request failed (${res.statusCode})').toString();
    throw ApiException(msg, statusCode: res.statusCode, payload: data);
  }

  /// Remove nulls and empty strings from a map
  Map<String, dynamic> _compact(Map<String, dynamic> src) {
    final out = <String, dynamic>{};
    src.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      out[k] = v;
    });
    return out;
  }
  /// Logout current device (revokes current token).
  Future<void> logout({bool localOnly = false}) async {
    final token = await _getToken();
    if (token != null && !localOnly) {
      final uri = Uri.parse('$baseUrl/api/auth/logout');
      await _client.post(uri, headers: _headers(authToken: token));
    }
    await _clearToken();
  }

  /// Logout all devices (revokes all tokens).
  Future<void> logoutAll() async {
    final token = await _getToken();
    if (token != null) {
      final uri = Uri.parse('$baseUrl/api/auth/logout-all');
      await _client.post(uri, headers: _headers(authToken: token));
    }
    await _clearToken();
  }

  Future<String?> currentToken() => _getToken();

  // ---------- Helpers ----------

  Map<String, String> _headers({String? authToken}) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  Map<String, dynamic> _decode(http.Response res) {
    try {
      final d = jsonDecode(res.body);
      return (d is Map) ? d.cast<String, dynamic>() : <String, dynamic>{'raw': d};
    } catch (_) {
      return {'success': false, 'message': 'Invalid server response', 'raw': res.body};
    }
  }

// Somewhere in AuthRepository (or your shared http utils).
  void _throwIfNotOk(http.Response res, Map<String, dynamic> data) {
    final code = res.statusCode;

    if (code >= 200 && code < 300) return;

    // 422 from Laravel ValidationException
    if (code == 422) {
      final errors = (data['errors'] as Map?)?.cast<String, dynamic>() ?? {};
      // Prefer known fields, then any field, then fallback to message
      final field = ['email', 'password'].firstWhere(
            (k) => errors[k] != null,
        orElse: () => errors.isNotEmpty ? errors.keys.first : '',
      );

      final msgs = (field.isNotEmpty ? errors[field] : null) as List?;
      final msg = (msgs != null && msgs.isNotEmpty)
          ? msgs.first.toString()
          : (data['message'] ?? 'Données invalides.').toString();

      throw ApiException(msg, statusCode: code, payload: data);
    }

    // 403, 401, 404, 500... use server message if present
    final serverMsg = (data['message'] ?? 'Une erreur s’est produite.').toString();
    throw ApiException(serverMsg, statusCode: code, payload: data);
  }


  Future<void> _saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_tokenKey, token);
  }

  Future<String?> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey);
  }

  Future<void> _clearToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_tokenKey);
  }
}
