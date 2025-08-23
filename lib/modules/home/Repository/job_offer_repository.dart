// lib/modules/home/repository/job_offer_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_finding/core/api_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/job_offer.dart';

class PageMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PageMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PageMeta.fromJson(Map<String, dynamic> json) => PageMeta(
    currentPage: int.tryParse(json['current_page']?.toString() ?? '') ?? 1,
    perPage: int.tryParse(json['per_page']?.toString() ?? '') ?? 15,
    total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
    lastPage: int.tryParse(json['last_page']?.toString() ?? '') ?? 1,
  );
}

class JobOfferResult {
  final List<JobOffer> data;
  final PageMeta? meta; // null when API returns a bare list

  const JobOfferResult({required this.data, this.meta});
}

class JobOfferRepository {
  static const _tokenKey = 'auth_token';

  final String baseUrl; // e.g. http://192.168.1.10:8000
  final http.Client _client;

  JobOfferRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Generic index that mirrors GET /api/job-offers
  ///
  /// Supports any params your backend expects, including:
  /// - filter: 'open' | 'all' | 'my-offer' | 'featured' | 'remote' | 'popular'('populer')
  /// - q, company_id, job_type, experience_level, city, governorate
  /// - min_salary, max_salary, deadline_before, deadline_after
  /// - include_closed, with_company, with_plans, remote_allowed, is_featured
  /// - sort, order, per_page, page
  /// - ids (List<int> / List<String>) -> sent as ids[]=1&ids[]=2
  /// - Category filters:
  ///   - category_id
  ///   - category_ids (List<int>) -> category_ids[]=1&category_ids[]=2
  ///   - category_slug
  ///   - category_slugs (List<String>) -> category_slugs[]=it&category_slugs[]=mobile
  ///   - category_mode ('all' | 'any')
  Future<JobOfferResult> index({Map<String, dynamic>? params}) async {
    final token = await _getToken();
    final uri = _uriWithParams('$baseUrl/api/job-offers', params ?? {});
    print(uri);
    final res = await _client.get(uri, headers: _headers(authToken: token));
    final decoded = _safeDecode(res.body);

    if (res.statusCode == 200 && decoded is List) {
      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map(_normalizeOfferJson)
          .map(JobOffer.fromJson)
          .toList();
      return JobOfferResult(data: list);
    }

    if (res.statusCode == 200 && decoded is Map<String, dynamic>) {
      final list = (decoded['data'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_normalizeOfferJson)
          .map(JobOffer.fromJson)
          .toList();
      final metaJson = decoded['meta'] as Map<String, dynamic>?;
      final meta = metaJson != null ? PageMeta.fromJson(metaJson) : null;
      return JobOfferResult(data: list, meta: meta);
    }
    if (res.statusCode == 429) {
      final body = jsonDecode(res.body);
      throw CooldownException(
        body['message'] ?? 'Cooldown actif.',
        statusCode: 429,
        payload: body,
        retryAfterSeconds: (body['retry_after_seconds'] is num)
            ? (body['retry_after_seconds'] as num).toInt()
            : null,
        retryAt: DateTime.tryParse(body['retry_at'] ?? ''),
      );
    }
    _throwHttp(decoded, res.statusCode);
    return const JobOfferResult(data: []);
  }

  Future<JobOfferResult> indexOpen({Map<String, dynamic>? params}) {
    return index(params: {'filter': 'open', ...?params});
  }

  Future<JobOfferResult> indexAll({Map<String, dynamic>? params}) {
    return index(params: {'filter': 'all', ...?params});
  }

  Future<JobOfferResult> indexMyOffers({Map<String, dynamic>? params}) {
    return index(params: {'filter': 'my-offer', ...?params});
  }

  Future<JobOfferResult> indexFeatured({Map<String, dynamic>? params}) {
    return index(params: {'filter': 'featured', ...?params});
  }

  Future<JobOfferResult> indexRemote({Map<String, dynamic>? params}) {
    return index(params: {'filter': 'remote', ...?params});
  }

  Future<JobOfferResult> indexPopular({Map<String, dynamic>? params}) {
    return index(params: {'filter': 'popular', ...?params});
  }

  Future<JobOffer> show(int id) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/api/job-offers/$id');

    final res = await _client.get(uri, headers: _headers(authToken: token));
    final decoded = _safeDecode(res.body);

    if (res.statusCode == 200 && decoded is Map<String, dynamic>) {
      return JobOffer.fromJson(_normalizeOfferJson(decoded));
    }

    _throwHttp(decoded, res.statusCode);
    throw Exception('Unable to load job offer');
  }

  Future<Map<String, List<String>>> meta() async {
    final uri = Uri.parse('$baseUrl/api/job-offers/meta');
    final res = await _client.get(uri, headers: _headers());

    final decoded = _safeDecode(res.body);
    if (res.statusCode == 200 && decoded is Map<String, dynamic>) {
      return {
        'types': (decoded['types'] as List? ?? const []).map((e) => e.toString()).toList(),
        'levels': (decoded['levels'] as List? ?? const []).map((e) => e.toString()).toList(),
        'statuses': (decoded['statuses'] as List? ?? const []).map((e) => e.toString()).toList(),
      };
    }

    _throwHttp(decoded, res.statusCode);
    return {'types': [], 'levels': [], 'statuses': []};
  }

  Future<String?> currentToken() => _getToken();

  Map<String, dynamic> _normalizeOfferJson(Map<String, dynamic> src) {
    final map = Map<String, dynamic>.from(src);
    final company = map['company'];
    if (company is String) {
      map['company'] = {'name': company};
    }
    return map;
  }

  Map<String, String> _headers({String? authToken}) => {
    'Content-Type': 'application/json',
    if (authToken != null && authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
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
        .toString()
        : 'Request failed ($status)'.toString();
    throw Exception(msg);
  }

  Future<String?> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey);
  }

  /// Build a URI with query params; supports arrays like key[]=a&key[]=b (Laravel-friendly).
  Uri _uriWithParams(String base, Map<String, dynamic> params) {
    if (params.isEmpty) return Uri.parse(base);

    final qp = <String, String>{};
    final listParams = <String, List<String>>{};

    params.forEach((key, value) {
      if (value == null) return;

      if (value is List) {
        if (value.isEmpty) return;
        listParams[key] = value.map((e) => e.toString()).toList();
      } else {
        qp[key] = value.toString();
      }
    });

    final buffer = StringBuffer();
    bool first = true;

    qp.forEach((k, v) {
      if (!first) buffer.write('&');
      buffer.write(Uri.encodeQueryComponent(k));
      buffer.write('=');
      buffer.write(Uri.encodeQueryComponent(v));
      first = false;
    });

    listParams.forEach((k, values) {
      for (final v in values) {
        if (!first) buffer.write('&');
        final key = k.endsWith('[]') ? k : '${k}[]';
        buffer.write(Uri.encodeQueryComponent(key));
        buffer.write('=');
        buffer.write(Uri.encodeQueryComponent(v));
        first = false;
      }
    });

    final sep = base.contains('?') ? '&' : '?';
    return Uri.parse('$base$sep${buffer.toString()}');
  }
}
