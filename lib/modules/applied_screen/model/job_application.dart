// lib/modules/applications/model/job_application.dart
import 'dart:convert';

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

bool _toBool(dynamic v, {bool fallback = false}) {
  if (v == null) return fallback;
  if (v is bool) return v;
  final s = v.toString().toLowerCase();
  if (s == '1' || s == 'true') return true;
  if (s == '0' || s == 'false') return false;
  return fallback;
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

String? _toStringN(dynamic v) => v == null ? null : v.toString();

List<String>? _toStringListOrNull(dynamic v) {
  if (v == null) return null;
  if (v is List) {
    final list = v.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    return list.isEmpty ? null : list;
  }
  // try JSON array
  try {
    final decoded = jsonDecode(v.toString());
    if (decoded is List) {
      final list = decoded.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      return list.isEmpty ? null : list;
    }
  } catch (_) {}
  // fallback: comma/newline separated string
  final parts = v
      .toString()
      .split(RegExp(r'[\r\n,]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  return parts.isEmpty ? null : parts;
}

/// Optional pagination meta (only present when backend returns { data, meta })
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

/// Model matches both list items and details payloads from your API.
class JobApplication {
  final int? id;

  // Owner & Offer
  final int? userId;
  final int? jobOfferId;
  final String? offerTitle; // list+details
  final String? company;    // list+details

  // Status / review
  final String? status;     // submitted|under_review|shortlisted|rejected|accepted
  final bool? reviewed;     // list item convenience (true if reviewed_at present)
  final bool? isFinal;      // either explicit or computed from status

  // Attachments / extra
  final String? cvFileUrl;
  final List<String>? additionalDocuments;

  // Reviewer info (details)
  final int? reviewedBy;
  final DateTime? reviewedAt;

  // Messages & timestamps
  final String? responseMessage;
  final DateTime? appliedAt;
  final DateTime? updatedAt;

  const JobApplication({
    this.id,
    this.userId,
    this.jobOfferId,
    this.offerTitle,
    this.company,
    this.status,
    this.reviewed,
    this.isFinal,
    this.cvFileUrl,
    this.additionalDocuments,
    this.reviewedBy,
    this.reviewedAt,
    this.responseMessage,
    this.appliedAt,
    this.updatedAt,
  });

  /// If API doesn't send is_final, compute from status.
  bool get computedIsFinal {
    if (isFinal != null) return isFinal!;
    final s = (status ?? '').toLowerCase();
    return s == 'accepted' || s == 'rejected';
  }

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    // The API sometimes uses 'offer_id' (list) and 'job_offer_id' (details).
    final offerId = _toInt(json['job_offer_id'] ?? json['offer_id']);

    return JobApplication(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      jobOfferId: offerId,
      offerTitle: _toStringN(json['offer_title']),
      company: _toStringN(json['company']),
      status: _toStringN(json['status']),
      reviewed: json['reviewed'] == null ? null : _toBool(json['reviewed']),
      isFinal: json['is_final'] == null ? null : _toBool(json['is_final']),
      cvFileUrl: _toStringN(json['cv_file_url']),
      additionalDocuments: _toStringListOrNull(json['additional_documents']),
      reviewedBy: _toInt(json['reviewed_by']),
      reviewedAt: _toDate(json['reviewed_at']),
      responseMessage: _toStringN(json['response_message']),
      appliedAt: _toDate(json['applied_at']),
      updatedAt: _toDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'job_offer_id': jobOfferId,
      'offer_title': offerTitle,
      'company': company,
      'status': status,
      'reviewed': reviewed,
      'is_final': isFinal ?? computedIsFinal,
      'cv_file_url': cvFileUrl,
      'additional_documents': additionalDocuments,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'response_message': responseMessage,
      'applied_at': appliedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static JobApplication fromJsonString(String str) =>
      JobApplication.fromJson(json.decode(str) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());
}
