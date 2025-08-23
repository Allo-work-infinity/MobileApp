// lib/payment/payment_pending_screen.dart
import 'package:flutter/material.dart';
import 'package:job_finding/modules/home/home_page.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/modules/auth/controller/auth_controller.dart';

import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_dimensions.dart';

import '../auth/model/user.dart';

class PaymentPendingScreen extends StatefulWidget {
  const PaymentPendingScreen({Key? key}) : super(key: key);

  @override
  State<PaymentPendingScreen> createState() => _PaymentPendingScreenState();
}

class _PaymentPendingScreenState extends State<PaymentPendingScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final auth = context.read<AuthController>();
    try {
      await auth.refreshUser();
      if (!mounted) return;

      final sub = auth.userSubscription; // <-- correct getter

      final isActive = auth.hasActiveSubscription ||
          ((sub?.status ?? '').toLowerCase() == 'active');

      final isPaid = ((sub?.paymentStatus ?? '').toLowerCase() == 'completed');

      if (isActive && isPaid) {
        // Go to Home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (_) => false,
        );
      } else {
        // Not active yet → show waiting message
        setState(() => _checking = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _checking = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final theme = Theme.of(context);

    // Loading screen while we check subscription status
    if (_checking || auth.loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vérification du paiement')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 28, height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
              SizedBox(height: 12),
              Text('Vérification de votre abonnement…'),
            ],
          ),
        ),
      );
    }

    // Cooldown (facultatif) : si votre backend impose une temporisation
    final cooldown = auth.cooldownActive ? auth.retryAt : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification du paiement')),
      body: Padding(
        padding: const EdgeInsets.all(Kdimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Kdimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: boarderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.schedule, color: secondaryColor, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paiement en attente',
                            style: theme.textTheme.subtitle1?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: navSelectedColor,
                            )),
                        const SizedBox(height: 6),
                        const Text(
                          "Votre paiement a bien été envoyé et est en attente de vérification par l’administrateur. "
                              "Vous serez notifié dès validation. En attendant, certaines fonctionnalités peuvent être limitées.",
                          style: TextStyle(color: paragraphColor, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // (Optionnel) Bloc d’info utilisateur
            if (auth.user != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Kdimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: boarderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: suffixColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.user!.name.isEmpty ? (auth.user!.email ?? 'Utilisateur') : auth.user!.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _StatusPill(text: 'En vérification'),
                  ],
                ),
              ),

            if (cooldown != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Kdimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: boarderColor),
                ),
                child: Text(
                  "Le serveur a imposé une temporisation. Réessayez après : ${cooldown.toLocal()}",
                  style: const TextStyle(color: paragraphColor),
                ),
              ),
            ],

            const Spacer(),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _checkSubscription,
                    child: const Text('Rafraîchir l’état'),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Kdimensions.paddingSizeSmall,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: boarderColor.withOpacity(.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: navSelectedColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
