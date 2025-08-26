// lib/modules/SubscriptionPlan/repository/subscription_plan_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_finding/modules/SubscriptionPlan/model/subscription_plan.dart';
// lib/modules/SubscriptionPlan/repository/subscription_plan_repository.dart

class PlanWithState {
  final PlanWithExtras plan;
  final SubscriptionMeta? latestSubscription;
  final bool isCurrent;

  PlanWithState({
    required this.plan,
    required this.latestSubscription,
    required this.isCurrent,
  });

  factory PlanWithState.fromJson(
      Map<String, dynamic> json,
      PlanWithExtras Function(Map<String, dynamic>) mapPlanWithExtras,
      ) {
    final planJson = (json['plan'] as Map?)?.cast<String, dynamic>() ?? const {};
    final latestJson = (json['latest_subscription'] as Map?)?.cast<String, dynamic>();
    return PlanWithState(
      plan: mapPlanWithExtras(planJson),
      latestSubscription: latestJson == null
          ? null
          : SubscriptionMeta.fromJson(Map<String, dynamic>.from(latestJson)),
      isCurrent: (json['is_current'] == true),
    );
  }
}

class CurrentPlanResponse {
  final PlanWithExtras? plan;            // current plan (if any)
  final SubscriptionMeta? subscription;  // current subscription meta
  final List<PlanWithState> plans;       // <-- all plans with latest sub + is_current

  CurrentPlanResponse({
    required this.plan,
    required this.subscription,
    required this.plans,
  });
}

/// Optional tiny model for included job offers
class JobOfferRef {
  final int id;
  final String title;

  JobOfferRef({required this.id, required this.title});

  factory JobOfferRef.fromJson(Map<String, dynamic> json) {
    return JobOfferRef(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
    );
  }
}

/// Wrapper that keeps your core SubscriptionPlan but also carries optional extras
class PlanWithExtras {
  final SubscriptionPlan plan;
  final int? jobOffersCount;
  final List<JobOfferRef>? jobOffers;

  PlanWithExtras({
    required this.plan,
    this.jobOffersCount,
    this.jobOffers,
  });
}

/// Metadata about the user's current/last subscription
class SubscriptionMeta {
  final int id;
  final String status;           // active | pending | expired | cancelled
  final String? paymentStatus;   // completed | pending | failed | refunded
  final String? paymentMethod;   // e.g. "card"
  final double? amountPaid;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool autoRenewal;
  final bool isCurrent;
  final int? remainingDays;

  const SubscriptionMeta({
    required this.id,
    required this.status,
    this.paymentStatus,
    this.paymentMethod,
    this.amountPaid,
    this.startDate,
    this.endDate,
    required this.autoRenewal,
    required this.isCurrent,
    this.remainingDays,
  });

  factory SubscriptionMeta.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return SubscriptionMeta(
      id: (json['id'] as num).toInt(),
      status: (json['status'] ?? '').toString(),
      paymentStatus: json['payment_status']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      amountPaid: _toDouble(json['amount_paid']),
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'].toString()) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'].toString()) : null,
      autoRenewal: (json['auto_renewal'] ?? false) == true,
      isCurrent: (json['is_current'] ?? false) == true,
      remainingDays: json['remaining_days'] == null ? null : (json['remaining_days'] as num).toInt(),
    );
  }
}

/// Response wrapper for /api/subscription/current-plan


class Paginated<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Paginated({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });
}

class SubscriptionPlanRepository {
  final String baseUrl; // e.g. http://10.0.2.2:8000
  final http.Client _client;
  final String? Function()? _tokenProvider;

  SubscriptionPlanRepository({
    required this.baseUrl,
    http.Client? client,
    String? Function()? tokenProvider,
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider;

  // -------------------- Public API --------------------

  /// GET /api/plans (non-paginated) — catalog
  Future<List<PlanWithExtras>> listPlans({
    String? q,
    bool? active, // default server-side = true
    bool includeJobOffers = false,
    bool withCounts = true,
  }) async {
    final params = <String, String>{
      if (q != null && q.isNotEmpty) 'q': q,
      if (active != null) 'active': active ? '1' : '0',
      if (includeJobOffers) 'include': 'job_offers',
      'with_counts': withCounts ? '1' : '0',
      'paginate': '0',
    };

    final uri = Uri.parse('$baseUrl/api/plans').replace(queryParameters: params);
    final res = await _client.get(uri, headers: await _jsonHeaders());

    final data = _decode(res);
    _throwIfNotOk(res, data);

    if (data is List) {
      return data
          .map((e) => _mapPlanWithExtras(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    throw Exception('Unexpected response format');
  }

  /// GET /api/plans (paginated) — catalog
  Future<Paginated<PlanWithExtras>> listPlansPaginated({
    String? q,
    bool? active, // default server-side = true
    bool includeJobOffers = false,
    bool withCounts = true,
    int perPage = 15,
    int page = 1,
  }) async {
    final params = <String, String>{
      if (q != null && q.isNotEmpty) 'q': q,
      if (active != null) 'active': active ? '1' : '0',
      if (includeJobOffers) 'include': 'job_offers',
      'with_counts': withCounts ? '1' : '0',
      'paginate': '1',
      'per_page': perPage.toString(),
      'page': page.toString(),
    };

    final uri = Uri.parse('$baseUrl/api/plans').replace(queryParameters: params);
    final res = await _client.get(uri, headers: await _jsonHeaders());

    final data = _decode(res);
    _throwIfNotOk(res, data);

    final items = (data['data'] as List)
        .map((e) => _mapPlanWithExtras(Map<String, dynamic>.from(e as Map)))
        .toList();

    return Paginated<PlanWithExtras>(
      items: items,
      currentPage: (data['current_page'] as num).toInt(),
      lastPage: (data['last_page'] as num).toInt(),
      perPage: (data['per_page'] as num).toInt(),
      total: (data['total'] as num).toInt(),
    );
  }

  /// GET /api/plans/{id} — single catalog plan
  Future<PlanWithExtras> getPlan(
      int id, {
        bool includeJobOffers = false,
        bool withCounts = true,
      }) async {
    final params = <String, String>{
      if (includeJobOffers) 'include': 'job_offers',
      'with_counts': withCounts ? '1' : '0',
    };

    final uri = Uri.parse('$baseUrl/api/plans/$id').replace(queryParameters: params);
    final res = await _client.get(uri, headers: await _jsonHeaders());

    final data = _decode(res);
    _throwIfNotOk(res, data);

    return _mapPlanWithExtras(Map<String, dynamic>.from(data as Map));
  }

  /// POST /api/subscriptions — subscribe to a plan
  Future<void> subscribe(int planId) async {
    final uri = Uri.parse('$baseUrl/api/subscriptions');
    final res = await _client.post(
      uri,
      headers: await _jsonHeaders(),
      body: jsonEncode({'plan_id': planId}),
    );

    final data = _decode(res);
    _throwIfNotOk(res, data);
  }

  /// GET /api/subscription/current-plan
  ///
  /// New API shape:
  /// {
  ///   "current": { "plan": {...} | null, "subscription": {...} | null },
  ///   "plans": [ ... ] // optional history (ignored here)
  /// }
  Future<CurrentPlanResponse> getMyCurrentPlan({
    bool includeJobOffers = false,
    bool withCounts = true,
  }) async {
    final params = <String, String>{
      if (includeJobOffers) 'include': 'job_offers',
      'with_counts': withCounts ? '1' : '0',
    };

    final uri = Uri.parse('$baseUrl/api/subscription/current-plan')
        .replace(queryParameters: params);
    final res = await _client.get(uri, headers: await _jsonHeaders());

    final data = _decode(res);
    _throwIfNotOk(res, data);

    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected response format');
    }

    // Support both nested and legacy shapes
    final current = (data['current'] as Map?)?.cast<String, dynamic>();
    final planJson = (current?['plan'] ?? data['plan']);
    final subJson  = (current?['subscription'] ?? data['subscription']);

    PlanWithExtras? plan;
    if (planJson is Map) {
      plan = _mapPlanWithExtras(Map<String, dynamic>.from(planJson.cast<String, dynamic>()));
    }

    SubscriptionMeta? sub;
    if (subJson is Map) {
      sub = SubscriptionMeta.fromJson(Map<String, dynamic>.from(subJson.cast<String, dynamic>()));
    }

    // NEW: parse the array of plans with latest_subscription
    final List<dynamic>? plansArr = data['plans'] as List?;
    final List<PlanWithState> allPlans = (plansArr ?? [])
        .whereType<Map>()
        .map((raw) => PlanWithState.fromJson(
      Map<String, dynamic>.from(raw.cast<String, dynamic>()),
          (m) => _mapPlanWithExtras(m),
    ))
        .toList();

    return CurrentPlanResponse(plan: plan, subscription: sub, plans: allPlans);
  }


  // -------------------- Internals --------------------

  Future<Map<String, String>> _jsonHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = _tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> _sendMultipart(http.MultipartRequest req) async {
    final streamed = await req.send();
    return http.Response.fromStream(streamed);
  }

  dynamic _decode(http.Response res) {
    try {
      return jsonDecode(res.body);
    } catch (_) {
      throw Exception('Invalid server response (${res.statusCode})');
    }
  }

  void _throwIfNotOk(http.Response res, dynamic data) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    final message = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'Request failed (${res.statusCode})';
    throw Exception(message);
  }

  PlanWithExtras _mapPlanWithExtras(Map<String, dynamic> json) {
    final plan = SubscriptionPlan.fromJson(json);

    int? jobOffersCount;
    final c = json['job_offers_count'];
    if (c is num) {
      jobOffersCount = c.toInt();
    } else if (c is String) {
      jobOffersCount = int.tryParse(c);
    }

    List<JobOfferRef>? offers;
    final raw = json['job_offers'];
    if (raw is List) {
      offers = raw
          .whereType<Map>()
          .map((e) => JobOfferRef.fromJson(Map<String, dynamic>.from(e.cast<String, dynamic>())))
          .toList();
    }

    return PlanWithExtras(
      plan: plan,
      jobOffersCount: jobOffersCount,
      jobOffers: offers,
    );
  }

  // --- Multipart helpers for manual payments (unchanged public API) ---
  Future<Map<String, dynamic>> submitManualPayment({
    required double amount,
    required String method,
    required String proofPath,
    String currency = 'TND',
    int? subscriptionId,
    String? manualReference,
    String? note,
  }) async {
    final uri = Uri.parse('$baseUrl/api/payment/manual');

    final req = http.MultipartRequest('POST', uri)
      ..fields['amount'] = amount.toStringAsFixed(2)
      ..fields['method'] = method
      ..fields['currency'] = currency;

    if (subscriptionId != null) req.fields['subscription_id'] = subscriptionId.toString();
    if (manualReference != null && manualReference.isNotEmpty) req.fields['manual_reference'] = manualReference;
    if (note != null && note.isNotEmpty) req.fields['note'] = note;

    req.files.add(await http.MultipartFile.fromPath('proof', proofPath));

    final token = _tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    req.headers['Accept'] = 'application/json';

    final res = await _sendMultipart(req);
    final data = _decode(res);
    _throwIfNotOk(res, data);

    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected response format from /api/payment/manual');
  }

  Future<Map<String, dynamic>> createSubscriptionFromManual({
    required int planId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/subscriptions/manual-from-transaction');

    final res = await _client.post(
      uri,
      headers: await _jsonHeaders(),
      body: jsonEncode({
        'plan_id': planId,
        'auto_renewal': false,
      }),
    );

    final data = _decode(res);
    _throwIfNotOk(res, data);

    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected response format from manual-from-transaction');
  }
}
