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

class PlanSummary {
  final int id;
  final String name;
  final double price;
  final int durationDays;

  PlanSummary({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
  });

  factory PlanSummary.fromJson(Map<String, dynamic> json) => PlanSummary(
    id: _toInt(json['id']) ?? 0,
    name: (json['name'] ?? '').toString(),
    price: _toDouble(json['price']) ?? 0.0,
    durationDays: _toInt(json['duration_days']) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'duration_days': durationDays,
  };
  // --- PlanSummary ---
  @override
  String toString() {
    return 'PlanSummary('
        'id: $id, '
        'name: $name, '
        'price: $price, '
        'durationDays: $durationDays'
        ')';
  }

}

class UserSubscriptionSummary {
  final int id;
  final String status;           // 'active' | 'expired' | ...
  final bool isCurrent;
  final int? remainingDays;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool autoRenewal;
  final String paymentStatus;
  final double? amountPaid;
  final PlanSummary? plan;

  UserSubscriptionSummary({
    required this.id,
    required this.status,
    required this.isCurrent,
    this.remainingDays,
    this.startDate,
    this.endDate,
    required this.autoRenewal,
    required this.paymentStatus,
    this.amountPaid,
    this.plan,
  });

  factory UserSubscriptionSummary.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionSummary(
      id: _toInt(json['id']) ?? 0,
      status: (json['status'] ?? '').toString(),
      isCurrent: json['is_current'] == true,
      remainingDays: _toInt(json['remaining_days']),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      autoRenewal: json['auto_renewal'] == true,
      paymentStatus: json['payment_status'],
      amountPaid: _toDouble(json['amount_paid']),
      plan: (json['plan'] is Map<String, dynamic>)
          ? PlanSummary.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'is_current': isCurrent,
    'remaining_days': remainingDays,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'auto_renewal': autoRenewal,
    'paymentStatus': paymentStatus,
    'amount_paid': amountPaid,
    'plan': plan?.toJson(),
  };
  // --- UserSubscriptionSummary ---
  @override
  String toString() {
    return 'UserSubscriptionSummary('
        'id: $id, '
        'status: $status, '
        'isCurrent: $isCurrent, '
        'remainingDays: $remainingDays, '
        'startDate: ${startDate?.toIso8601String()}, '
        'endDate: ${endDate?.toIso8601String()}, '
        'autoRenewal: $autoRenewal, '
        'amountPaid: $amountPaid, '
        'plan: ${plan?.toString()}'
        ')';
  }

}

class User {
  final int? id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? governorate;
  final String? profilePictureUrl;
  final String? cvFileUrl;
  final bool isEmailVerified;
  final String? status;              // active | suspended | banned
  final DateTime? lastAccessTime;
  final bool isAdmin;

  // Optional token (if ever embedded inside user)
  final String? token;

  // NEW from /auth/login
  final bool hasActiveSubscription;
  final UserSubscriptionSummary? subscription;

  String get name => "${firstName ?? ''} ${lastName ?? ''}".trim();

  User({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.dateOfBirth,
    this.address,
    this.city,
    this.governorate,
    this.profilePictureUrl,
    this.cvFileUrl,
    this.isEmailVerified = false,
    this.status,
    this.lastAccessTime,
    this.isAdmin = false,
    this.token,
    this.hasActiveSubscription = false,
    this.subscription,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'].toString())
          : null,
      address: json['address'] as String?,
      city: json['city'] as String?,
      governorate: json['governorate'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      cvFileUrl: json['cv_file_url'] as String?,
      isEmailVerified: json['is_email_verified'] == true,
      status: json['status'] as String?,
      lastAccessTime: json['last_access_time'] != null
          ? DateTime.tryParse(json['last_access_time'].toString())
          : null,
      isAdmin: json['is_admin'] == true,
      token: json['token'] as String?,

      // Injected by repo.login()
      hasActiveSubscription: json['has_active_subscription'] == true,
      subscription: (json['subscription'] is Map<String, dynamic>)
          ? UserSubscriptionSummary.fromJson(
        json['subscription'] as Map<String, dynamic>,
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'address': address,
      'city': city,
      'governorate': governorate,
      'profile_picture_url': profilePictureUrl,
      'cv_file_url': cvFileUrl,
      'is_email_verified': isEmailVerified,
      'status': status,
      'last_access_time': lastAccessTime?.toIso8601String(),
      'is_admin': isAdmin,
      'token': token,

      'has_active_subscription': hasActiveSubscription,
      'subscription': subscription?.toJson(),
    };
  }

  static User fromJsonString(String str) =>
      User.fromJson(json.decode(str) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());
  // --- User ---
  @override
  String toString() {
    return 'User('
        'id: $id, '
        'email: $email, '
        'firstName: $firstName, '
        'lastName: $lastName, '
        'phone: $phone, '
        'dateOfBirth: ${dateOfBirth?.toIso8601String()}, '
        'address: $address, '
        'city: $city, '
        'governorate: $governorate, '
        'profilePictureUrl: $profilePictureUrl, '
        'cvFileUrl: $cvFileUrl, '
        'isEmailVerified: $isEmailVerified, '
        'status: $status, '
        'lastAccessTime: ${lastAccessTime?.toIso8601String()}, '
        'isAdmin: $isAdmin, '
    // mask token to avoid leaking secrets in logs
        'token: ${token == null ? null : '***'}, '
        'hasActiveSubscription: $hasActiveSubscription, '
        'subscription: ${subscription?.toString()}'
        ')';
  }

}
