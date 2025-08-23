// lib/modules/home/model/job_offer.dart
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

List<String> _toStringList(dynamic v) {
  if (v == null) return const [];
  if (v is List) {
    return v.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
  }
  // fallback for comma-separated
  return v.toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

/// Minimal company snapshot for list/detail usage.
class CompanyLite {
  final int? id;
  final String? name;
  final String? logoUrl;

  const CompanyLite({this.id, this.name, this.logoUrl});

  factory CompanyLite.fromJson(dynamic json) {
    // Accept both: a string name or an object with id/name/logo_url
    if (json is String) {
      return CompanyLite(id: null, name: json, logoUrl: null);
    }
    if (json is Map<String, dynamic>) {
      return CompanyLite(
        id: _toInt(json['id']),
        name: _toStringN(json['name']),
        logoUrl: _toStringN(json['logo_url']),
      );
    }
    return const CompanyLite();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo_url': logoUrl,
  };
}

class JobOffer {
  final int? id;
  final int? companyId;
  final int? categoryId;

  final String? title;
  final String? description;
  final String? requirements;
  final String? responsibilities;
  final String? reference;
  /// Strings (simple): 'full_time' | 'part_time' | 'contract' | 'internship' | 'remote'
  final String? jobType;

  /// Strings: 'entry' | 'junior' | 'mid' | 'senior' | 'lead'
  final String? experienceLevel;

  final double? salaryMin;
  final double? salaryMax;
  final String? currency;

  final String? location;
  final String? city;
  final String? governorate;

  final bool remoteAllowed;
  final List<String> skillsRequired;
  final List<String> benefits;

  final DateTime? applicationDeadline;
  final bool isFeatured;

  /// Strings: 'draft' | 'active' | 'paused' | 'closed'
  final String? status;

  final int viewsCount;
  final int applicationsCount;

  /// Company snapshot (id, name, logo_url). Will also be populated if API returns
  /// top-level 'company' (string) and/or 'logo_url' (string).
  final CompanyLite? company;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Optional computed (if API sends it). If null, you can compute on demand.
  final bool? isOpen;

  const JobOffer({
    this.id,
    this.companyId,
    this.categoryId,
    this.title,
    this.description,
    this.requirements,
    this.responsibilities,
    this.jobType,
    this.experienceLevel,
    this.salaryMin,
    this.salaryMax,
    this.currency,
    this.location,
    this.city,
    this.governorate,
    this.remoteAllowed = false,
    this.skillsRequired = const [],
    this.benefits = const [],
    this.applicationDeadline,
    this.isFeatured = false,
    this.status,
    this.viewsCount = 0,
    this.applicationsCount = 0,
    this.company,
    this.reference,
    this.createdAt,
    this.updatedAt,
    this.isOpen,
  });

  /// If API didn't provide is_open, you can compute lazily with this getter.
  bool get computedIsOpen {
    if ((status ?? '') != 'active') return false;
    if (applicationDeadline == null) return true;
    final now = DateTime.now();
    final d = applicationDeadline!;
    return d.isAfter(now) || d.isAtSameMomentAs(now);
  }

  JobOffer copyWith({
    int? id,
    int? companyId,
    int? categoryId,
    String? title,
    String? description,
    String? requirements,
    String? responsibilities,
    String? jobType,
    String? experienceLevel,
    double? salaryMin,
    double? salaryMax,
    String? currency,
    String? location,
    String? city,
    String? governorate,
    bool? remoteAllowed,
    List<String>? skillsRequired,
    List<String>? benefits,
    DateTime? applicationDeadline,
    bool? isFeatured,
    String? status,
    int? viewsCount,
    int? applicationsCount,
    CompanyLite? company,
    String? reference,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOpen,
  }) {
    return JobOffer(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      responsibilities: responsibilities ?? this.responsibilities,
      jobType: jobType ?? this.jobType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      currency: currency ?? this.currency,
      location: location ?? this.location,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      remoteAllowed: remoteAllowed ?? this.remoteAllowed,
      skillsRequired: skillsRequired ?? this.skillsRequired,
      benefits: benefits ?? this.benefits,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
      viewsCount: viewsCount ?? this.viewsCount,
      applicationsCount: applicationsCount ?? this.applicationsCount,
      company: company ?? this.company,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  factory JobOffer.fromJson(Map<String, dynamic> json) {
    // Company can be nested or flat
    CompanyLite? company;
    if (json.containsKey('company') && json['company'] != null) {
      company = CompanyLite.fromJson(json['company']);
    }
    // Allow top-level 'company' (string) and 'logo_url' fields (from simplified index)
    final topLogoUrl = _toStringN(json['logo_url']);
    if (company == null && (json['company'] != null || topLogoUrl != null)) {
      company = CompanyLite(
        id: _toInt(json['company_id']),
        name: _toStringN(json['company']),
        logoUrl: topLogoUrl,
      );
    } else if (company != null && topLogoUrl != null && company.logoUrl == null) {
      // merge a top-level logo_url onto a nested company if provided
      company = CompanyLite(id: company.id, name: company.name, logoUrl: topLogoUrl);
    }

    return JobOffer(
      id: _toInt(json['id']),
      companyId: _toInt(json['company_id']),
      categoryId: _toInt(json['category_id']),
      title: _toStringN(json['title']),
      description: _toStringN(json['description']),
      requirements: _toStringN(json['requirements']),
      responsibilities: _toStringN(json['responsibilities']),
      jobType: _toStringN(json['job_type']),
      experienceLevel: _toStringN(json['experience_level']),
      salaryMin: _toDouble(json['salary_min']),
      salaryMax: _toDouble(json['salary_max']),
      currency: _toStringN(json['currency']) ?? 'TND',
      location: _toStringN(json['location']),
      city: _toStringN(json['city']),
      governorate: _toStringN(json['governorate']),
      remoteAllowed: _toBool(json['remote_allowed']),
      skillsRequired: _toStringList(json['skills_required']),
      benefits: _toStringList(json['benefits']),
      applicationDeadline: _toDate(json['application_deadline']),
      isFeatured: _toBool(json['is_featured']),
      status: _toStringN(json['status']),
      viewsCount: _toInt(json['views_count']) ?? 0,
      applicationsCount: _toInt(json['applications_count']) ?? 0,
      company: company,
      reference : _toStringN(json['reference']),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      isOpen: json['is_open'] == null ? null : _toBool(json['is_open']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'job_type': jobType,
      'experience_level': experienceLevel,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'currency': currency,
      'location': location,
      'city': city,
      'governorate': governorate,
      'remote_allowed': remoteAllowed,
      'skills_required': skillsRequired,
      'benefits': benefits,
      'application_deadline': applicationDeadline?.toIso8601String(),
      'is_featured': isFeatured,
      'status': status,
      'views_count': viewsCount,
      'applications_count': applicationsCount,
      // Prefer nested company JSON for serialization
      'company': company?.toJson(),
      'reference': reference,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      // If you want to also emit top-level logo_url (handy for lists), keep this:
      if (company?.logoUrl != null) 'logo_url': company!.logoUrl,
    };
  }

  static JobOffer fromJsonString(String str) =>
      JobOffer.fromJson(json.decode(str) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());
}
