
class Company {
  final int id;
  final String name;
  final String? description;
  final String? industry;
  final String? companySize;
  final String? website;
  final String? logoUrl;
  final String? address;
  final String? city;
  final String? governorate;
  final String? contactEmail;
  final String? contactPhone;
  final bool isVerified;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Company({
    required this.id,
    required this.name,
    this.description,
    this.industry,
    this.companySize,
    this.website,
    this.logoUrl,
    this.address,
    this.city,
    this.governorate,
    this.contactEmail,
    this.contactPhone,
    this.isVerified = false,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      industry: json['industry'] as String?,
      companySize: json['company_size'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logo_url'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      governorate: json['governorate'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      isVerified: (json['is_verified'] ?? false) as bool,
      status: (json['status'] ?? 'active') as String,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }
}