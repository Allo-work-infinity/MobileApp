// lib/payment/select_payment_method_screen.dart
import 'package:flutter/material.dart';
import 'package:job_finding/modules/SubscriptionPlan/manual_payment_screen.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_dimensions.dart';

// Paiement (Konnect)
import 'package:job_finding/modules/SubscriptionPlan/controller/payment_controller.dart';
import 'package:job_finding/modules/SubscriptionPlan/payment_screen.dart';

class SelectPaymentMethodScreen extends StatefulWidget {
  /// ID du plan d'abonnement (tu passes actuellement plan.id)
  final int subscriptionId;

  /// Montant à payer (facultatif, purement affichage)
  final double? amount;

  /// Devise (ex: 'TND'). Par défaut: 'TND'
  final String? currency;

  /// Description du paiement (ex: 'Subscription: Premium')
  final String? description;

  const SelectPaymentMethodScreen({
    Key? key,
    required this.subscriptionId,
    this.amount,
    this.currency,
    this.description,
  }) : super(key: key);

  @override
  State<SelectPaymentMethodScreen> createState() =>
      _SelectPaymentMethodScreenState();
}

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  bool _buying = false;

  String get _currency => (widget.currency ?? 'TND');
  double get _amount => (widget.amount ?? 0.0);

  Future<void> _payWithCard() async {
    if (_buying) return;

    setState(() => _buying = true);
    try {
      final planId = widget.subscriptionId;

      // TODO: récupère le vrai token Konnect depuis ton form/SDK.
      // Placeholder pour garder ta logique actuelle :
      final konnectToken = _currency; // 'TND'

      final paymentCtrl = context.read<PaymentController>();

      final ok = await paymentCtrl.initPayment(
        subscriptionPlanId: planId,
        konnectToken: konnectToken, // backend renvoie payUrl / paymentRef
        description: widget.description ?? 'Subscription',
        savePendingTransaction: false,
        userSubscriptionId: null,
      );

      if (!mounted) return;

      if (ok && paymentCtrl.redirectUrl != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebViewPaiment(
              redirectUrl: paymentCtrl.redirectUrl!,
              konnectPaymentId: paymentCtrl.konnectPaymentId ?? '',
              subscriptionId: planId,
              amount: _amount,
              currency: _currency,
              paymentMethod: "card",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(paymentCtrl.error ?? 'Failed to start payment')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  void _goManual() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/payment/manual'),
        builder: (_) => ManualPaymentScreen(
          amount: _amount,
          subscriptionId: widget.subscriptionId// passes the double to the screen constructor
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountLine = (_amount > 0)
        ? Text(
      'Total: ${_amount.toStringAsFixed(2)} $_currency',
      style: Theme.of(context)
          .textTheme
          .headline6
          ?.copyWith(color: navSelectedColor),
    )
        : const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Select payment method')),
      body: Padding(
        padding: const EdgeInsets.all(Kdimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            amountLine,
            const SizedBox(height: 12),
            _MethodCard(
              title: 'Visa / Mastercard',
              subtitle: _buying ? 'Starting checkout…' : 'Pay securely with your bank card',
              onTap: _buying ? null : _payWithCard,
              leading: const Icon(Icons.credit_card, color: secondaryColor),
            ),
            const SizedBox(height: 12),
            _MethodCard(
              title: 'Manual (Tunisia)',
              subtitle: 'Virement Bancaire or D17',
              onTap: _goManual,
              leading: const Icon(Icons.account_balance, color: secondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback? onTap;
  final Widget leading;
  const _MethodCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: boarderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Kdimensions.paddingSizeLarge),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: captionTextColor)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: suffixColor),
            ],
          ),
        ),
      ),
    );
  }
}
