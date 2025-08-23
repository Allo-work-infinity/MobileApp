// lib/modules/categories/repository/category_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_finding/modules/home/model/Category.dart';
import 'package:shared_preferences/shared_preferences.dart';



/// --- Repository ---
class CategoryRepository {
  static const _tokenKey = 'auth_token';

  final String baseUrl; // e.g. http://192.168.1.10:8000
  final http.Client _client;

  CategoryRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// GET /api/categories
  /// Your simple controller returns all categories (no pagination).
  Future<List<CategoryModel>> index() async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/api/categories');

    final res = await _client.get(uri, headers: _headers(authToken: token));
    final decoded = _safeDecode(res.body);

    if (res.statusCode == 200 && decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
    }

    _throwHttp(decoded, res.statusCode);
    return const []; // safety
  }

  /// GET /api/categories/{idOrSlug}
  Future<CategoryModel> show(String idOrSlug) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/api/categories/$idOrSlug');

    final res = await _client.get(uri, headers: _headers(authToken: token));
    final decoded = _safeDecode(res.body);

    if (res.statusCode == 200 && decoded is Map<String, dynamic>) {
      return CategoryModel.fromJson(decoded);
    }

    _throwHttp(decoded, res.statusCode);
    throw Exception('Unable to load category'); // safety
  }

  // ---------- Helpers ----------

  Map<String, String> _headers({String? authToken}) => {
    'Content-Type': 'application/json',
    if (authToken != null && authToken.isNotEmpty)
      'Authorization': 'Bearer $authToken',
  };

  dynamic _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {'success': false, 'message': 'Invalid server response'};
    }
  }

  Never _throwHttp(dynamic decoded, int status) {
    final msg = (decoded is Map<String, dynamic>)
        ? (decoded['message'] ??
        decoded['error'] ??
        decoded['errors']?.toString() ??
        'Request failed ($status)')
        : 'Request failed ($status)';
    throw Exception(msg);
  }

  Future<String?> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey);
  }
}
