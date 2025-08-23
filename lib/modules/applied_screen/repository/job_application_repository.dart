// lib/modules/applications/repository/job_application_repository.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/job_application.dart';

class JobApplicationResult {
  final List<JobApplication> data;
  final PageMeta? meta; // null when API returns a bare list

  const JobApplicationResult({required this.data, this.meta});
}

class JobApplicationRepository {
  static const _tokenKey = 'auth_token';

  final String baseUrl; // e.g. http://192.168.1.193:8000
  final http.Client _client;

  JobApplicationRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // =====================================================
  // Public API
  // =====================================================

  /// GET /api/job-applications
  /// Optional params:
  /// q, status, job_offer_id, from, to, per_page, page
  Future<JobApplicationResult> index({Map<String, dynamic>? params}) async {
    final token = await _getToken();
    final uri = _uriWithParams('$baseUrl/api/job-applications', params ?? {});

    final res = await _client.get(uri, headers: _jsonHeaders(token));
    final decoded = _safeDecode(res.body);

    // Two shapes:
    // 1) []  (no pagination)
    // 2) { data: [...], meta: {...} }
    if (res.statusCode == 200 && decoded is List) {
      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map(JobApplication.fromJson)
          .toList();
      return JobApplicationResult(data: list);
    }

    if (res.statusCode == 200 && decoded is Map<String, dynamic>) {
      final list = (decoded['data'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(JobApplication.fromJson)
          .toList();
      final metaJson = decoded['meta'] as Map<String, dynamic>?;
      final meta = metaJson != null ? PageMeta.fromJson(metaJson) : null;
      return JobApplicationResult(data: list, meta: meta);
    }

    _throwHttp(decoded, res.statusCode);
    return const JobApplicationResult(data: []); // safety
  }

  /// GET /api/job-applications/{id}
  Future<JobApplication> show(int id) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/api/job-applications/$id');

    final res = await _client.get(uri, headers: _jsonHeaders(token));
    final decoded = _safeDecode(res.body);

    if (res.statusCode == 200 && decoded is Map<String, dynamic>) {
      return JobApplication.fromJson(decoded);
    }

    _throwHttp(decoded, res.statusCode);
    throw Exception('Unable to load application');
  }

  /// POST /api/job-applications
  /// Apply to an offer. You can pass:
  /// - [cvFile] to upload a file (pdf/doc/docx)
  /// - [cvFileUrl] if you already have a URL
  /// - [additionalDocuments] as a list of strings
  Future<JobApplication> create({
    required int jobOfferId,
    File? cvFile,
    String? cvFileUrl,
    List<String>? additionalDocuments,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/api/job-applications');

    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(_authHeader(token)); // no Content-Type here
    req.fields['job_offer_id'] = jobOfferId.toString();

    if (cvFileUrl != null && cvFileUrl.isNotEmpty) {
      req.fields['cv_file_url'] = cvFileUrl;
    }
    if (additionalDocuments != null) {
      req.fields['additional_documents'] = jsonEncode(additionalDocuments);
    }
    if (cvFile != null) {
      req.files.add(await http.MultipartFile.fromPath('cv', cvFile.path));
    }

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    final decoded = _safeDecode(body);

    if ((streamed.statusCode == 200 || streamed.statusCode == 201) &&
        decoded is Map<String, dynamic>) {
      return JobApplication.fromJson(decoded);
    }

    _throwHttp(decoded, streamed.statusCode);
    throw Exception('Unable to create application');
  }

  /// PATCH /api/job-applications/{id}
  /// Update CV (file or URL) and/or additional_documents.
  Future<JobApplication> update(
      int id, {
        File? cvFile,
        String? cvFileUrl,
        List<String>? additionalDocuments,
      }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/api/job-applications/$id');

    // Use multipart for both file/no-file to keep it simple
    final req = http.MultipartRequest('PATCH', uri);
    req.headers.addAll(_authHeader(token));

    if (cvFileUrl != null) {
      req.fields['cv_file_url'] = cvFileUrl;
    }
    if (additionalDocuments != null) {
      req.fields['additional_documents'] = jsonEncode(additionalDocuments);
    }
    if (cvFile != null) {
      req.files.add(await http.MultipartFile.fromPath('cv', cvFile.path));
    }

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    final decoded = _safeDecode(body);

    if (streamed.statusCode == 200 && decoded is Map<String, dynamic>) {
      return JobApplication.fromJson(decoded);
    }

    _throwHttp(decoded, streamed.statusCode);
    throw Exception('Unable to update application');
  }

  /// DELETE /api/job-applications/{id}
  Future<void> destroy(int id) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/api/job-applications/$id');

    final res = await _client.delete(uri, headers: _jsonHeaders(token));
    if (res.statusCode >= 200 && res.statusCode < 300) return;

    final decoded = _safeDecode(res.body);
    _throwHttp(decoded, res.statusCode);
  }

  // =====================================================
  // Helpers
  // =====================================================

  Map<String, String> _jsonHeaders(String? token) => {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Map<String, String> _authHeader(String? token) => {
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
        : 'Request failed ($status)';
    throw Exception(msg);
  }

  Future<String?> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey);
  }

  /// Build a URI with query params; supports arrays via repeating the key (e.g., ids[]=1&ids[]=2).
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
