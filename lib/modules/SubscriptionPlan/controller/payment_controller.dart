// lib/modules/payment/controller/payment_controller.dart
import 'package:flutter/foundation.dart';
import 'package:job_finding/core/api_exceptions.dart';
import 'package:job_finding/modules/SubscriptionPlan/model/payment_transaction.dart';

import '../repository/payment_repository.dart';
import '../repository/payment_transaction_repository.dart';

class PaymentController extends ChangeNotifier {
  final PaymentRepositoryHttp paymentRepo;
  final PaymentTransactionRepositoryHttp? txRepo;

  // You can keep this for future use (synced from AuthController), but repos are token-aware already.
  String? _bearerToken;

  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? _rawInitResponse;
  String? _konnectPaymentId; // Konnect: paymentRef
  String? _redirectUrl;      // Konnect: payUrl

  PaymentTransaction? _lastTransaction;

  PaymentController({
    required this.paymentRepo,
    this.txRepo,
    String? bearerToken,
  }) : _bearerToken = bearerToken;

  // ====== getters ======
  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, dynamic>? get rawInitResponse => _rawInitResponse;
  String? get konnectPaymentId => _konnectPaymentId;
  String? get redirectUrl => _redirectUrl;

  PaymentTransaction? get lastTransaction => _lastTransaction;

  // ====== setters ======
  void setBearerToken(String? token) => _bearerToken = token; // optional; repos fetch token themselves

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _rawInitResponse = null;
    _konnectPaymentId = null;
    _redirectUrl = null;
    _lastTransaction = null;
    notifyListeners();
  }

  /// Initializes a Konnect payment via your Laravel endpoint.
  ///
  /// For hosted checkout, pass `konnectToken = null` so backend returns { payUrl, paymentRef }.
  /// If [savePendingTransaction] is true and [userSubscriptionId] is provided,
  /// we immediately create a 'pending' PaymentTransaction.
  Future<bool> initPayment({
    required int subscriptionPlanId,
    String? konnectToken,
    String? description,
    bool savePendingTransaction = false,
    int? userSubscriptionId,
  }) async {
    _setLoading(true);

    try {
      final response = await paymentRepo.initPayment(
        subscriptionPlanId: subscriptionPlanId,
        token: konnectToken, // omitted if null/empty by repo
        description: description,
      );

      _rawInitResponse = response;

      // shape: { response: 'Success', data: {...} }
      final data = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : const <String, dynamic>{};

      _konnectPaymentId = _extractPaymentId(data);   // paymentRef
      _redirectUrl      = _extractRedirectUrl(data); // payUrl

      // Optionally save a pending transaction
      if (savePendingTransaction && txRepo != null && _konnectPaymentId != null) {
        if (userSubscriptionId == null) {
          debugPrint('[PaymentController] userSubscriptionId is null; skipping transaction save.');
        } else {
          _lastTransaction = await txRepo!.create(
            subscriptionId: userSubscriptionId,
            konnectPaymentId: _konnectPaymentId!,
            status: PaymentStatus.pending,
            konnectResponse: data,
          );
        }
      }

      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(_friendlyMessage(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Submit a manual payment with proof image (bank transfer or D17).
  ///
  /// - [method] must be 'bank_transfer' or 'd17'
  /// - [proofPath] is a local file path (from ImagePicker)
  /// - returns response Map from the API (contains transaction_id, etc.)
  // Future<Map<String, dynamic>?> submitManualPayment({
  //   required double amount,
  //   required String method,       // 'bank_transfer' | 'd17'
  //   required String proofPath,
  //   String currency = 'TND',
  //   int? subscriptionId,
  //   String? manualReference,
  //   String? note,
  // }) async {
  //   _setLoading(true);
  //   try {
  //     final resp = await paymentRepo.submitManualPayment(
  //       amount: amount,
  //       method: method,
  //       proofPath: proofPath,
  //       currency: currency,
  //       subscriptionId: subscriptionId,
  //       manualReference: manualReference,
  //       note: note,
  //     );
  //     _setLoading(false);
  //     return resp;
  //   } on ApiException catch (e) {
  //     _setError(_friendlyMessage(e));
  //     return null;
  //   } catch (e) {
  //     _setError(e.toString());
  //     return null;
  //   }
  // }

  /// Public helper to create a transaction directly (mirrors repo `create(...)`).
  Future<PaymentTransaction?> createTransaction({
    required int subscriptionId,
    required String konnectPaymentId,
    String? konnectTransactionId,
    double? amount,
    String currency = 'TND',
    String? paymentMethod,
    PaymentStatus status = PaymentStatus.pending,
    Map<String, dynamic>? konnectResponse,
    String? failureReason,
    DateTime? processedAt,
  }) async {
    if (txRepo == null) return null;
    _setLoading(true);
    try {
      final tx = await txRepo!.create(
        subscriptionId: subscriptionId,
        konnectPaymentId: konnectPaymentId,
        konnectTransactionId: konnectTransactionId,
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        status: status,
        konnectResponse: konnectResponse,
        failureReason: failureReason,
        processedAt: processedAt,
      );
      _lastTransaction = tx;
      _setLoading(false);
      return tx;
    } on ApiException catch (e) {
      _setError(_friendlyMessage(e));
      return null;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }
  /// Submit a manual payment with proof image (bank transfer or D17).
  ///
  /// - [method] must be 'bank_transfer' or 'd17'
  /// - [proofPath] is a local file path (from ImagePicker)
  /// Returns the backend JSON map (e.g. { status, transaction_id, proof_url, ... }).
  Future<Map<String, dynamic>> submitManualPayment({
    required double amount,
    required String method,       // 'bank_transfer' | 'd17'
    required String proofPath,
    String currency = 'TND',
    int? subscriptionId,
    String? manualReference,
    String? note,
  }) async {
    _setLoading(true);
    try {
      final resp = await paymentRepo.submitManualPayment(
        amount: amount,
        method: method,
        proofPath: proofPath,
        currency: currency,
        subscriptionId: subscriptionId,
        manualReference: manualReference,
        note: note,
      );
      _setLoading(false);
      return resp; // non-nullable
    } on ApiException catch (e) {
      _setError(_friendlyMessage(e));
      rethrow; // keep non-null contract; let caller handle
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  /// Mark transaction completed.
  Future<PaymentTransaction?> markTransactionCompleted({
    required int transactionId,
    String? konnectTransactionId,
    Map<String, dynamic>? konnectResponse,
  }) async {
    if (txRepo == null) return null;
    _setLoading(true);
    try {
      final updated = await txRepo!.update(
        id: transactionId,
        status: PaymentStatus.completed,
        konnectTransactionId: konnectTransactionId,
        konnectResponse: konnectResponse,
      );
      _lastTransaction = updated;
      _setLoading(false);
      return updated;
    } on ApiException catch (e) {
      _setError(_friendlyMessage(e));
      return null;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Mark transaction failed.
  Future<PaymentTransaction?> markTransactionFailed({
    required int transactionId,
    String? failureReason,
    Map<String, dynamic>? konnectResponse,
  }) async {
    if (txRepo == null) return null;
    _setLoading(true);
    try {
      final updated = await txRepo!.update(
        id: transactionId,
        status: PaymentStatus.failed,
        konnectResponse: konnectResponse,
        failureReason: failureReason,
      );
      _lastTransaction = updated;
      _setLoading(false);
      return updated;
    } on ApiException catch (e) {
      _setError(_friendlyMessage(e));
      return null;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // ====== private helpers ======
  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? msg) { _isLoading = false; _error = msg; notifyListeners(); }

  String _friendlyMessage(ApiException e) {
    if (e.statusCode == 401) return 'Unauthorized';
    if (e.statusCode == 404) return 'Endpoint not found';
    return e.message;
  }

  /// Include Konnect variants: paymentRef/payUrl
  String? _extractPaymentId(Map<String, dynamic> data) {
    final candidates = [
      'paymentRef', 'payment_ref',            // Konnect
      'paymentId', 'payment_id', 'id', 'reference',
    ];
    for (final k in candidates) {
      final v = data[k];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    final meta = data['meta'];
    if (meta is Map && meta['paymentRef'] != null) {
      return meta['paymentRef'].toString();
    }
    return null;
  }

  String? _extractRedirectUrl(Map<String, dynamic> data) {
    final candidates = [
      'payUrl', 'pay_url',                    // Konnect
      'redirectUrl', 'redirect_url', 'redirect', 'url',
    ];
    for (final k in candidates) {
      final v = data[k];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    final links = data['links'];
    if (links is Map) {
      for (final k in ['pay', 'checkout', 'redirect']) {
        final v = links[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
    }
    return null;
  }
}
