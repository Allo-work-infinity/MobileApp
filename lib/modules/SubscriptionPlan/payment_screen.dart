// ignore_for_file: unnecessary_null_comparison, non_constant_identifier_names, use_build_context_synchronously, prefer_const_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:job_finding/modules/SubscriptionPlan/controller/payment_controller.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Controllers
import 'package:job_finding/modules/SubscriptionPlan/controller/plan_controller.dart';
import 'package:job_finding/modules/SubscriptionPlan/model/payment_transaction.dart';
import 'package:job_finding/modules/auth/controller/auth_controller.dart'; // if you have it
import 'package:job_finding/router_name.dart'; // for Routes.home (or swap to your HomeScreen)

class WebViewPaiment extends StatefulWidget {
  final String redirectUrl;
  final String konnectPaymentId;

  // Extra info from caller (use real user_subscription.id when you have it)
  final int? subscriptionId;     // currently you pass plan.id
  final double? amount;
  final String? currency;        // e.g. 'TND'
  final String? paymentMethod;   // e.g. 'card'

  const WebViewPaiment({
    Key? key,
    required this.redirectUrl,
    required this.konnectPaymentId,
    this.subscriptionId,
    this.amount,
    this.currency,
    this.paymentMethod,
  }) : super(key: key);

  @override
  State<WebViewPaiment> createState() => _WebViewPaimentState();
}

class _WebViewPaimentState extends State<WebViewPaiment> {
  late WebViewController controller;
  double progress = 0.0;

  // Konnect redirect URLs (must match what your backend config uses)
  static const String _successBase = 'https://dev.konnect.network/gateway/payment-success';
  static const String _failureBase = 'https://dev.konnect.network/gateway/payment-failure';

  String _paymentRef = '';
  bool _busy = false;      // overlay
  bool _handled = false;   // prevent double handling

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _paymentRef = widget.konnectPaymentId;
  }

  NavigationDecision _onNav(NavigationRequest req) {
    final url = req.url;
    final uri = Uri.tryParse(url);
    if (uri == null) return NavigationDecision.navigate;

    final isSuccess = url.startsWith(_successBase);
    final isFailure = url.startsWith(_failureBase);

    final refFromUrl = uri.queryParameters['payment_ref'];
    if (refFromUrl != null && refFromUrl.isNotEmpty) {
      _paymentRef = refFromUrl;
    }

    if (isSuccess) {
      _handlePaymentSuccess(_paymentRef);
      return NavigationDecision.prevent; // do NOT load success page
    }
    if (isFailure) {
      _handlePaymentFailure(_paymentRef);
      return NavigationDecision.prevent; // do NOT load failure page
    }
    return NavigationDecision.navigate;
  }

  Future<void> _handlePaymentSuccess(String paymentRef) async {
    if (_handled) return;
    _handled = true;

    final planCtrl = context.read<PlanController>();
    final payCtrl  = context.read<PaymentController>();
    final authCtrl = context.read<AuthController>();

    // BEFORE we subscribe: did the user already have an active subscription?
    final bool hadActiveBefore = authCtrl.user?.hasActiveSubscription ?? false;

    setState(() => _busy = true);

    try {
      // 1) Subscribe (your backend should accept the plan id)
      if (widget.subscriptionId != null) {
        await planCtrl.subscribeToPlan(widget.subscriptionId!);
      }

      // 2) Save COMPLETED transaction only if txRepo is wired
      if (payCtrl.txRepo != null) {
        await payCtrl.createTransaction(
          subscriptionId: widget.subscriptionId ?? 0, // TODO: replace with real user_subscription.id if/when you have it
          konnectPaymentId: paymentRef,
          amount: widget.amount,
          currency: widget.currency ?? 'TND',
          paymentMethod: widget.paymentMethod ?? 'card',
          status: PaymentStatus.completed,
        );
      }

      // 3) Refresh user
      await authCtrl.refreshUser();

      if (!mounted) return;

      // 4) Notify
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement réussi. Abonnement activé.')),
      );

      // 5) Navigate: first-time subscribers go to account, others to home
      final String target = hadActiveBefore ? Routes.home : Routes.accountScreen;
      Navigator.of(context).pushNamedAndRemoveUntil(target, (_) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _handled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur après succès paiement: $e')),
      );
    }
  }


  Future<void> _handlePaymentFailure(String paymentRef) async {
    setState(() => _busy = true);
    final payCtrl  = context.read<PaymentController>();

    try {
      // Optionally record FAILED transaction
      if (widget.subscriptionId != null) {
        await payCtrl.createTransaction(
          subscriptionId: widget.subscriptionId!,
          konnectPaymentId: paymentRef,
          amount: widget.amount,
          currency: widget.currency ?? 'TND',
          paymentMethod: widget.paymentMethod ?? 'card',
          status: PaymentStatus.failed,
          failureReason: 'Payment failed on gateway',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le paiement a échoué.')),
      );

      // Reload checkout to allow retry
      setState(() { _busy = false; _handled = false; });
      controller.loadUrl(widget.redirectUrl);
    } catch (e) {
      if (!mounted) return;
      setState(() { _busy = false; _handled = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur en enregistrant l’échec: $e')),
      );
      controller.loadUrl(widget.redirectUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: const Text('Paiement',style: TextStyle(color: Colors.black),),
          actions: [
            IconButton(
              onPressed: () => controller.reload(),
              icon: const Icon(Icons.refresh),
              color: Colors.black,
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                if (progress < 1.0)
                  LinearProgressIndicator(value: progress),
                Expanded(
                  child: WebView(
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: widget.redirectUrl,
                    onWebViewCreated: (WebViewController c) {
                      controller = c;
                    },
                    navigationDelegate: _onNav, // <-- intercept success/failure
                    onProgress: (p) => setState(() => progress = p / 100),
                    onWebResourceError: (err) {
                      // Optional: show an inline error or reload
                      // print('Web error: $err');
                    },
                  ),
                ),
              ],
            ),

            // Busy overlay
            if (_busy)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: const Center(
                    child: SizedBox(
                      width: 48, height: 48,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
