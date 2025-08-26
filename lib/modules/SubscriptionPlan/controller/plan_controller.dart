// lib/modules/SubscriptionPlan/controller/plan_controller.dart
import 'package:flutter/foundation.dart';

import '../repository/subscription_plan_repository.dart';
import '../model/subscription_plan.dart';

class PlanController extends ChangeNotifier {
  final SubscriptionPlanRepository _repo;

  PlanController(this._repo);
  List<PlanWithState> myPlansWithMeta = [];
  // ---------- State ----------
  bool loading = false;
  bool loadingMore = false;
  String? error;

  // Manual payment state (NEW)
  bool manualSubmitting = false;
  int? lastManualTransactionId;
  int? lastManualSubscriptionId;
  String? lastManualStatus; // e.g. "pending"
  String? lastProofUrl;

  // Filters
  String q = '';
  bool? active = true; // null = all, true = only active, false = inactive
  bool includeJobOffers = false;
  bool withCounts = true;

  // Non-paginated list (catalog OR account list depending on loader used)
  List<PlanWithExtras> plans = [];

  // Paginated list
  List<PlanWithExtras> pageItems = [];
  int currentPage = 1;
  int lastPage = 1;
  int perPage = 15;
  int total = 0;

  // Selected / details
  PlanWithExtras? selected;

  // ---------- My current subscription plan ----------
  bool loadingMyPlan = false;
  PlanWithExtras? myPlan;              // null if user has no current plan
  SubscriptionMeta? mySubscription;    // meta: status, dates, etc.

  bool get hasActiveSubscription => mySubscription?.isCurrent == true;

  // ---------- Helpers ----------
  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setLoadingMore(bool v) {
    loadingMore = v;
    notifyListeners();
  }

  void _setError(String? e) {
    error = e;
    notifyListeners();
  }

  void _setManualSubmitting(bool v) {
    manualSubmitting = v;
    notifyListeners();
  }

  void clearManualState() {
    lastManualTransactionId = null;
    lastManualSubscriptionId = null;
    lastManualStatus = null;
    lastProofUrl = null;
    notifyListeners();
  }

  // ---------- Non-paginated (catalog) ----------
  Future<void> loadPlans() async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _repo.listPlans(
        q: q.isEmpty ? null : q,
        active: active,
        includeJobOffers: includeJobOffers,
        withCounts: withCounts,
      );
      plans = result; // full catalog
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// NEW: For Account screen — load ONLY the user’s subscribed plan
  /// and expose it through `plans` so existing UI shows just one card.
  Future<void> loadPlansForAccount() async {
    _setLoading(true);
    _setError(null);
    try {
      final resp = await _repo.getMyCurrentPlan(
        includeJobOffers: includeJobOffers,
        withCounts: withCounts,
      );
      myPlan = resp.plan;
      mySubscription = resp.subscription;

      // Show ONLY the subscribed plan in the list used by _SubscriptionCard
      plans = (resp.plan != null) ? [resp.plan!] : [];
    } catch (e) {
      plans = [];
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ---------- Paginated (catalog) ----------
  Future<void> loadFirstPage({int? perPageOverride}) async {
    _setLoading(true);
    _setError(null);
    try {
      currentPage = 1;
      if (perPageOverride != null && perPageOverride > 0) {
        perPage = perPageOverride;
      }

      final page = await _repo.listPlansPaginated(
        q: q.isEmpty ? null : q,
        active: active,
        includeJobOffers: includeJobOffers,
        withCounts: withCounts,
        perPage: perPage,
        page: currentPage,
      );

      pageItems
        ..clear()
        ..addAll(page.items);

      currentPage = page.currentPage;
      lastPage = page.lastPage;
      total = page.total;

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (loadingMore || currentPage >= lastPage) return;
    _setLoadingMore(true);
    _setError(null);
    try {
      final nextPage = currentPage + 1;
      final page = await _repo.listPlansPaginated(
        q: q.isEmpty ? null : q,
        active: active,
        includeJobOffers: includeJobOffers,
        withCounts: withCounts,
        perPage: perPage,
        page: nextPage,
      );
      pageItems.addAll(page.items);
      currentPage = page.currentPage;
      lastPage = page.lastPage;
      total = page.total;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoadingMore(false);
    }
  }

  // ---------- Single ----------
  Future<void> getPlan(int id, {bool? includeOffers, bool? counts}) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _repo.getPlan(
        id,
        includeJobOffers: includeOffers ?? includeJobOffers,
        withCounts: counts ?? withCounts,
      );
      selected = result;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ---------- My current subscription ----------
  Future<void> loadMyCurrentPlan({
    bool? includeOffers,
    bool? counts,
  }) async {
    loadingMyPlan = true;
    _setError(null);
    notifyListeners();
    try {
      final resp = await _repo.getMyCurrentPlan(
        includeJobOffers: includeOffers ?? includeJobOffers,
        withCounts: counts ?? withCounts,
      );
      myPlan = resp.plan;
      mySubscription = resp.subscription;
      myPlansWithMeta = resp.plans;  // <-- keep the full list for UI
    } catch (e) {
      _setError(e.toString());
    } finally {
      loadingMyPlan = false;
      notifyListeners();
    }
  }



  void clearMyCurrentPlan() {
    myPlan = null;
    mySubscription = null;
    notifyListeners();
  }

  // ---------- Filters / actions ----------
  void setQuery(String value, {bool autoReload = false, bool paginated = false}) {
    q = value.trim();
    notifyListeners();
    if (autoReload) {
      paginated ? loadFirstPage() : loadPlans();
    }
  }

  void setActiveFilter(bool? value, {bool autoReload = false, bool paginated = false}) {
    active = value; // null = all
    notifyListeners();
    if (autoReload) {
      paginated ? loadFirstPage() : loadPlans();
    }
  }

  void setIncludeJobOffers(bool value, {bool autoReload = false, bool paginated = false}) {
    includeJobOffers = value;
    notifyListeners();
    if (autoReload) {
      paginated ? loadFirstPage() : loadPlans();
    }
  }

  void setWithCounts(bool value, {bool autoReload = false, bool paginated = false}) {
    withCounts = value;
    notifyListeners();
    if (autoReload) {
      paginated ? loadFirstPage() : loadPlans();
    }
  }

  Future<void> refresh({bool paginated = false}) async {
    return paginated ? loadFirstPage() : loadPlans();
  }

  void clearError() {
    _setError(null);
  }

  Future<void> subscribeToPlan(int planId) async {
    try {
      loading = true;
      notifyListeners();
      await _repo.subscribe(planId);
      error = null;
      // Optionally refresh the current plan after subscribing
      // await loadPlansForAccount();
      // await loadMyCurrentPlan();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Manual Payment Flow (NEW)
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> submitManualPayment({
    required double amount,
    required String method,      // 'bank_transfer' | 'd17'
    required String proofPath,   // local file path
    String currency = 'TND',
    int? subscriptionId,
    String? manualReference,
    String? note,
  }) async {
    _setManualSubmitting(true);
    _setError(null);
    try {
      final resp = await _repo.submitManualPayment(
        amount: amount,
        method: method,
        proofPath: proofPath,
        currency: currency,
        subscriptionId: subscriptionId,
        manualReference: manualReference,
        note: note,
      );

      lastManualTransactionId = (resp['transaction_id'] as num?)?.toInt();
      lastManualStatus = resp['status_label']?.toString() ?? resp['status']?.toString();
      lastProofUrl = resp['proof_url']?.toString();

      return resp;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setManualSubmitting(false);
    }
  }

  Future<Map<String, dynamic>> createSubscriptionFromManual({
    required int planId,
    required int transactionId, // keep signature clear even if backend links internally
    bool autoRenewal = false,
  }) async {
    _setManualSubmitting(true);
    _setError(null);
    try {
      final resp = await _repo.createSubscriptionFromManual(
        planId: planId,
      );

      lastManualSubscriptionId = (resp['subscription_id'] as num?)?.toInt();

      // Refresh "my current plan" to reflect pending state
      await loadMyCurrentPlan();

      return resp;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setManualSubmitting(false);
    }
  }

  Future<Map<String, dynamic>> manualPayAndCreateSubscription({
    required int planId,
    required double amount,
    required String method,      // 'bank_transfer' | 'd17'
    required String proofPath,
    String currency = 'TND',
    bool autoRenewal = false,
    String? manualReference,
    String? note,
  }) async {
    _setManualSubmitting(true);
    _setError(null);
    try {
      final subResp = await _repo.createSubscriptionFromManual(
        planId: planId,
      );

      final subId = (subResp['subscription_id'] as num?)?.toInt();
      if (subId == null) {
        throw Exception('Missing subscription_id from manual subscription response');
      }

      final paymentResp = await submitManualPayment(
        amount: amount,
        method: method,
        proofPath: proofPath,
        currency: currency,
        subscriptionId: subId,
        manualReference: manualReference,
        note: note,
      );

      lastManualSubscriptionId = subId;
      lastManualTransactionId = (paymentResp['transaction_id'] as num?)?.toInt();
      lastManualStatus = paymentResp['status_label']?.toString() ?? paymentResp['status']?.toString();
      lastProofUrl = paymentResp['proof_url']?.toString();

      await loadMyCurrentPlan();

      return {
        'subscription': subResp,
        'payment': paymentResp,
      };
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setManualSubmitting(false);
    }
  }
}
