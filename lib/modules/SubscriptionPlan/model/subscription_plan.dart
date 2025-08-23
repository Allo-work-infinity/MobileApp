import 'dart:convert';

class SubscriptionPlan {
  final int? id;
  final String name;
  final String? description;
  /// Laravel casts price as decimal:3. We keep it as double and round to 3 dp on output.
  final double price;
  final int durationDays;
  /// `features` is stored as JSON array in Laravel. We model it as a list of strings.
  final List<String> features;
  final bool isActive;

  // Optional timestamps if your API includes them
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubscriptionPlan({
    this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationDays,
    List<String>? features,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  }) : features = features ?? const [];

  /// Robust numeric parsing (handles int/double/string)
  static double _toDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static List<String> _toStringList(dynamic v) {
    if (v == null) return <String>[];
    if (v is List) {
      return v.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    }
    // If backend sends a JSON string instead of array
    if (v is String) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is List) {
          return decoded.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
        }
      } catch (_) {}
    }
    return <String>[];
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int?,
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      price: _toDouble(json['price']),
      durationDays: _toInt(json['duration_days']),
      features: _toStringList(json['features']),
      isActive: (json['is_active'] == null) ? true : (json['is_active'] == true || json['is_active'] == 1),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Round price to 3 decimals to match Laravel cast(decimal:3)
    double round3(double v) => (v * 1000).round() / 1000.0;

    return {
      'id': id,
      'name': name,
      'description': description,
      'price': round3(price),
      'duration_days': durationDays,
      'features': features, // will serialize as JSON array
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  SubscriptionPlan copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? durationDays,
    List<String>? features,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convenience helpers
  static List<SubscriptionPlan> listFromJson(dynamic data) {
    if (data is List) {
      return data.map((e) => SubscriptionPlan.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    return const [];
  }

  factory SubscriptionPlan.fromJsonString(String source) =>
      SubscriptionPlan.fromJson(json.decode(source) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());
}
