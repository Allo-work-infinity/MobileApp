// payment_transaction.dart
import 'dart:convert';

/// Matches Laravel statuses: pending | completed | failed | cancelled
enum PaymentStatus { pending, completed, failed, cancelled }

extension PaymentStatusX on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.completed:
        return 'completed';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.cancelled:
        return 'cancelled';
    }
  }

  bool get isFinal =>
      this == PaymentStatus.completed ||
          this == PaymentStatus.failed ||
          this == PaymentStatus.cancelled;

  bool get isSuccessful => this == PaymentStatus.completed;

  static PaymentStatus from(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }
}

class PaymentTransaction {
  /// Common Laravel fields
  final int? id;

  // DB columns
  final int? userId;
  final int? subscriptionId; // user_subscriptions.id (FK)
  final String? konnectPaymentId;
  final String? konnectTransactionId;
  final double? amount; // decimal(10,3) in Laravel; parsed from num or string
  final String currency; // default 'TND'
  final String? paymentMethod;
  final PaymentStatus status;
  final Map<String, dynamic>? konnectResponse;
  final String? failureReason;
  final DateTime? processedAt;

  // Timestamps (likely present in API)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentTransaction({
    this.id,
    this.userId,
    this.subscriptionId,
    this.konnectPaymentId,
    this.konnectTransactionId,
    this.amount,
    this.currency = 'TND',
    this.paymentMethod,
    this.status = PaymentStatus.pending,
    this.konnectResponse,
    this.failureReason,
    this.processedAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Convenience getters mirroring Laravel accessors
  bool get isFinal => status.isFinal;
  bool get isSuccessful => status.isSuccessful;

  PaymentTransaction copyWith({
    int? id,
    int? userId,
    int? subscriptionId,
    String? konnectPaymentId,
    String? konnectTransactionId,
    double? amount,
    String? currency,
    String? paymentMethod,
    PaymentStatus? status,
    Map<String, dynamic>? konnectResponse,
    String? failureReason,
    DateTime? processedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      konnectPaymentId: konnectPaymentId ?? this.konnectPaymentId,
      konnectTransactionId: konnectTransactionId ?? this.konnectTransactionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      konnectResponse: konnectResponse ?? this.konnectResponse,
      failureReason: failureReason ?? this.failureReason,
      processedAt: processedAt ?? this.processedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Robust JSON parser for Laravel responses
  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      subscriptionId: _asInt(json['subscription_id']),
      konnectPaymentId: _asString(json['konnect_payment_id']),
      konnectTransactionId: _asString(json['konnect_transaction_id']),
      amount: _asDouble(json['amount']),
      currency: _asString(json['currency']) ?? 'TND',
      paymentMethod: _asString(json['payment_method']),
      status: PaymentStatusX.from(_asString(json['status'])),
      konnectResponse: _asMap(json['konnect_response']),
      failureReason: _asString(json['failure_reason']),
      processedAt: _asDate(json['processed_at']),
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
    );
  }

  /// If your API returns the transaction nested (e.g., as a string), handy helper:
  factory PaymentTransaction.fromJsonString(String source) =>
      PaymentTransaction.fromJson(jsonDecode(source) as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subscription_id': subscriptionId,
      'konnect_payment_id': konnectPaymentId,
      'konnect_transaction_id': konnectTransactionId,
      // keep 3 decimals like Laravel cast('decimal:3'), but OK if null
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'status': status.value,
      'konnect_response': konnectResponse,
      'failure_reason': failureReason,
      'processed_at': _dateToString(processedAt),
      'created_at': _dateToString(createdAt),
      'updated_at': _dateToString(updatedAt),
    };
  }

  @override
  String toString() =>
      'PaymentTransaction(id: $id, userId: $userId, subscriptionId: $subscriptionId, '
          'status: ${status.value}, amount: $amount $currency, isFinal: $isFinal, isSuccessful: $isSuccessful)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentTransaction &&
        other.id == id &&
        other.userId == userId &&
        other.subscriptionId == subscriptionId &&
        other.konnectPaymentId == konnectPaymentId &&
        other.konnectTransactionId == konnectTransactionId &&
        other.amount == amount &&
        other.currency == currency &&
        other.paymentMethod == paymentMethod &&
        other.status == status &&
        _mapEquals(other.konnectResponse, konnectResponse) &&
        other.failureReason == failureReason &&
        other.processedAt == processedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      Object.hashAll([
        id,
        userId,
        subscriptionId,
        konnectPaymentId,
        konnectTransactionId,
        amount,
        currency,
        paymentMethod,
        status,
        _mapHash(konnectResponse),
        failureReason,
        processedAt,
        createdAt,
        updatedAt,
      ]);

  // ---------- Private helpers ----------

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      // Laravel decimals may come as "12.500"
      final s = v.replaceAll(',', '.');
      return double.tryParse(s);
    }
    return null;
  }

  static String? _asString(dynamic v) {
    if (v == null) return null;
    return v.toString();
  }

  static Map<String, dynamic>? _asMap(dynamic v) {
    if (v == null) return null;
    if (v is Map<String, dynamic>) return v;
    if (v is Map) {
      return v.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      // Supports "2025-08-20T08:40:00.000000Z" or "2025-08-20 08:40:00"
      return DateTime.tryParse(v.replaceFirst(' ', 'T'));
    }
    return null;
  }

  static String? _dateToString(DateTime? dt) => dt?.toUtc().toIso8601String();

  static bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  static int _mapHash(Map<String, dynamic>? m) {
    if (m == null) return 0;
    return Object.hashAll(m.entries.map((e) => Object.hash(e.key, e.value)));
  }
}
