import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_finding/modules/job_details/model/company.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic payload;
  const ApiException(this.message, {this.statusCode, this.payload});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NotFoundException extends ApiException {
  const NotFoundException(String message) : super(message, statusCode: 404);
}

class CompanyRepositoryHttp {
  static const _tokenKey = 'auth_token';

  final String baseUrl;
  final Map<String, String> _baseHeaders;
  final http.Client _client;
  final Duration _timeout;

  CompanyRepositoryHttp({
    required this.baseUrl, // e.g. http://192.168.1.193:8000
    http.Client? client,
    Map<String, String>? defaultHeaders,
    Duration timeout = const Duration(seconds: 20),
  })  : _client = client ?? http.Client(),
        _timeout = timeout,
        _baseHeaders = {
          'Accept': 'application/json',
          if (defaultHeaders != null) ...defaultHeaders,
        };

  // ---------- Public API ----------

  /// POST with JSON body { "id": <id> }
  Future<Company> getByIdPost(int id, {String path = '/api/companies/show'}) async {
    final token = await _getToken();
    final res = await _client
        .post(
      _uri(path),
      headers: _headers(authToken: token, json: true),
      body: jsonEncode({'id': id}),
    )
        .timeout(_timeout);
    return _parseCompanyFromApi(res);
  }

  /// GET with query ?id=<id>
  Future<Company> getByIdGet(int id, {String path = '/api/companies/show'}) async {
    final token = await _getToken();
    final res = await _client
        .get(
      _uri(path, {'id': id}),
      headers: _headers(authToken: token),
    )
        .timeout(_timeout);
    return _parseCompanyFromApi(res);
  }

  /// One method to choose POST or GET
  Future<Company> getById(int id, {bool usePost = true, String path = '/api/companies/show'}) {
    return usePost ? getByIdPost(id, path: path) : getByIdGet(id, path: path);
  }

  /// Safe version: returns null on 404
  Future<Company?> findById(int id, {bool usePost = true, String path = '/api/companies/show'}) async {
    try {
      return await getById(id, usePost: usePost, path: path);
    } on NotFoundException {
      return null;
    }
  }

  Future<String?> currentToken() => _getToken();

  void close() => _client.close();

  // ---------- Helpers ----------

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final qp = <String, String>{};
    query?.forEach((k, v) {
      if (v != null) qp[k] = v.toString();
    });
    return Uri.parse('$base$path').replace(queryParameters: qp.isEmpty ? null : qp);
  }

  Map<String, String> _headers({String? authToken, bool json = false}) {
    return {
      ..._baseHeaders,
      if (json) 'Content-Type': 'application/json',
      if (authToken != null && authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };
  }

  Map<String, dynamic> _decodeBody(http.Response res) {
    dynamic body;
    try {
      body = jsonDecode(res.body);
    } catch (_) {
      throw ApiException('Invalid JSON response', statusCode: res.statusCode, payload: res.body);
    }
    if (body is! Map<String, dynamic>) {
      throw ApiException('Unexpected response shape', statusCode: res.statusCode, payload: body);
    }
    return body;
  }

  Company _parseCompanyFromApi(http.Response res) {
    if (res.statusCode == 404) {
      throw const NotFoundException('Company not found');
    }
    if (res.statusCode != 200) {
      // Try to surface API error message when available
      String? msg;
      try {
        final parsed = jsonDecode(res.body);
        if (parsed is Map && parsed['message'] != null) {
          msg = parsed['message'].toString();
        }
      } catch (_) {}
      throw ApiException(msg ?? 'Unexpected status ${res.statusCode}',
          statusCode: res.statusCode, payload: res.body);
    }
    final map = _decodeBody(res);
    final data = map['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Malformed payload: "data" is missing or not an object');
    }
    return Company.fromJson(data);
  }

  Future<String?> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey);
  }
}
