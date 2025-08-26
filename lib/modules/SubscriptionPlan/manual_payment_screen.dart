// lib/payment/manual_payment_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_finding/modules/auth/controller/auth_controller.dart';
import 'package:job_finding/router_name.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/modules/SubscriptionPlan/controller/plan_controller.dart';
import 'package:job_finding/modules/SubscriptionPlan/payment_pending_screen.dart';

import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_dimensions.dart';

enum ManualMethod { bank, d17 }

class ManualPaymentScreen extends StatefulWidget {
  final double amount;
  final int subscriptionId;
  const ManualPaymentScreen({Key? key, required this.amount,required this.subscriptionId,}) : super(key: key);

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  ManualMethod _method = ManualMethod.bank;
  File? _proof;
  bool _localSubmitting = false;

  // TODO: remplacez par vos vraies valeurs (affichage/infos)
  static const _beneficiary = 'Your Company Name';
  static const _bankName = 'Attijari Bank';
  static const _ribIban = 'TN59 10XX XXXX XXXX XXXX XXXX';
  static const _reference = 'Subscription Plan ABC'; // référence à saisir
  static const _d17Code = 'MERCHANT1234'; // code marchand D17

  Future<void> _pickProof() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (x != null) setState(() => _proof = File(x.path));
  }

  Future<void> _submitProof() async {
    if (_proof == null) {
      _snack('Veuillez joindre une preuve de paiement (image).');
      return;
    }

    final planCtrl = context.read<PlanController>();
    final authCtrl = context.read<AuthController>();
    // final planId = planCtrl.selected?.plan.id;
    //
    // if (planId == null) {
    //   _snack("Aucun plan sélectionné. Ouvrez d'abord l'écran d’un plan puis réessayez.");
    //   return;
    // }

    setState(() => _localSubmitting = true);
    try {
      // Appelle le flux complet :
      // 1) /api/payment/manual (upload preuve)
      // 2) /api/subscriptions/manual-from-transaction (crée l’abonnement en pending)
      final bool hadActiveBefore = authCtrl.user?.hasActiveSubscription ?? false;
      await planCtrl.manualPayAndCreateSubscription(
        planId: widget.subscriptionId,
        amount: widget.amount,
        method: _method == ManualMethod.bank ? 'bank_transfer' : 'd17',
        proofPath: _proof!.path,
        currency: 'TND',
        autoRenewal: false,
        manualReference: _method == ManualMethod.bank ? _reference : _d17Code,
        note: 'Paiement manuel depuis l’application mobile',
      );

      if (!mounted) return;
      setState(() => _localSubmitting = false);

      // Succès => informer puis aller sur l’écran “en attente de vérification”
      // await showDialog<void>(
      //   context: context,
      //   builder: (_) => const AlertDialog(
      //     title: Text('Envoyé'),
      //     content: Text(
      //       'Votre preuve de paiement a été envoyée.\n'
      //           'Un abonnement en attente de vérification a été créé. Nous vous informerons bientôt.',
      //     ),
      //   ),
      // );

      if (!mounted) return;
      final String target = hadActiveBefore ? Routes.accountScreen: Routes.home;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PaymentPendingScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _localSubmitting = false);
      _snack("Erreur : $e");
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final isBank = _method == ManualMethod.bank;
    final planCtrl = context.watch<PlanController>();
    final submitting = _localSubmitting || planCtrl.manualSubmitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement manuel (Tunisie)')),
      body: Padding(
        padding: const EdgeInsets.all(Kdimensions.paddingSizeDefault),
        child: ListView(
          children: [
            Text(
              'Total : ${widget.amount.toStringAsFixed(2)} TND',
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                color: navSelectedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Aide visuelle: quel plan est sélectionné ?
            if (planCtrl.selected?.plan.name != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Plan sélectionné : ${planCtrl.selected!.plan.name}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

            _MethodSelector(
              method: _method,
              onChanged: (m) => setState(() => _method = m),
            ),
            const SizedBox(height: 16),

            // Instructions
            Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: boarderColor),
              ),
              padding: const EdgeInsets.all(Kdimensions.paddingSizeLarge),
              child: isBank ? const _BankInstructions() : const _D17Instructions(),
            ),

            const SizedBox(height: 16),

            // Upload proof
            Text(
              'Joindre une preuve (capture/photo) :',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(height: 8),
            if (_proof != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_proof!, height: 160, fit: BoxFit.cover),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: submitting ? null : _pickProof,
              icon: const Icon(Icons.upload),
              label: const Text('Choisir une image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitting ? null : _submitProof,
              child: submitting
                  ? const SizedBox(
                  height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor))
                  : const Text('Envoyer pour vérification'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodSelector extends StatelessWidget {
  final ManualMethod method;
  final ValueChanged<ManualMethod> onChanged;
  const _MethodSelector({Key? key, required this.method, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tile(
        ManualMethod m,
        String title,
        String subtitle,
        IconData icon,
        ) {
      final selected = method == m;
      return InkWell(
        onTap: () => onChanged(m),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? secondaryColor : boarderColor,
              width: selected ? 2 : 1,
            ),
            color: primaryColor,
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? secondaryColor : suffixColor),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: captionTextColor),
                    ),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: secondaryColor),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        tile(
          ManualMethod.bank,
          'Virement bancaire',
          'Virez sur notre compte bancaire en Tunisie',
          Icons.account_balance,
        ),
        const SizedBox(height: 10),
        tile(
          ManualMethod.d17,
          'D17 (e-Dinar / La Poste)',
          'Payez via D17 puis envoyez le reçu',
          Icons.phone_iphone,
        ),
      ],
    );
  }
}

class _BankInstructions extends StatelessWidget {
  const _BankInstructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // (Texte d'exemple — remplacez par vos coordonnées réelles)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Comment payer par virement bancaire :',
            style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text(
          '1) Depuis votre application bancaire/guichet, effectuez un virement avec les informations ci-dessous.\n'
              '2) Indiquez la référence exactement comme indiqué.\n'
              '3) Téléversez la preuve du virement puis validez pour vérification.',
          style: TextStyle(color: paragraphColor),
        ),
        SizedBox(height: 12),
        Divider(),
        SizedBox(height: 8),
        Text('Bénéficiaire : Your Company Name',
            style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        Text(
          'Banque : Attijari Bank • RIB/IBAN : TN59 10XX XXXX XXXX XXXX XXXX\n'
              'Référence : Subscription Plan ABC',
          style: TextStyle(color: paragraphColor),
        ),
      ],
    );
  }
}

class _D17Instructions extends StatelessWidget {
  const _D17Instructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // (Texte d'exemple — remplacez par vos coordonnées réelles)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Comment payer via D17 :',
            style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text(
          '1) Ouvrez l’application D17 (La Poste) ou rendez-vous à un agent.\n'
              '2) Choisissez paiement/virement et utilisez notre code marchand/référence.\n'
              '3) Finalisez le paiement puis prenez une capture/photo du reçu.\n'
              '4) Joignez l’image ici et envoyez pour vérification.',
          style: TextStyle(color: paragraphColor),
        ),
        SizedBox(height: 12),
        Divider(),
        SizedBox(height: 8),
        Text('Code marchand / Référence : MERCHANT1234',
            style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        Text(
          'Le montant sera rapproché de votre compte après vérification.',
          style: TextStyle(color: paragraphColor),
        ),
      ],
    );
  }
}
