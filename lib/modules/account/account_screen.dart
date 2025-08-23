// lib/modules/account/account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/modules/SubscriptionPlan/plan_details_screen.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/widget/appbar_button.dart';
import 'package:job_finding/widget/profile_image_view.dart';

// Auth
import 'package:job_finding/modules/auth/controller/auth_controller.dart';

// Plans
import 'package:job_finding/modules/SubscriptionPlan/controller/plan_controller.dart';
import 'package:job_finding/modules/SubscriptionPlan/model/subscription_plan.dart';
import 'package:job_finding/modules/SubscriptionPlan/plans_screen.dart';
import 'package:job_finding/modules/SubscriptionPlan/repository/subscription_plan_repository.dart'
    show PlanWithExtras, SubscriptionMeta; // for the meta type

// Optional: your profile screen
import 'package:job_finding/modules/profile/profile_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _didRequestMyPlan = false;
  bool _didRequestPlans = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final planCtrl = context.read<PlanController>();

    if (!_didRequestMyPlan) {
      _didRequestMyPlan = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        planCtrl.loadMyCurrentPlan();
      });
    }

    if (!_didRequestPlans) {
      _didRequestPlans = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        planCtrl.loadPlans();      // <-- load catalog so plansList isn’t empty
      });
    }
  }

  String _displayName(AuthController auth) {
    final u = auth.user;
    if (u == null) return '—';
    final first = (u.firstName ?? '').trim();
    final last = (u.lastName ?? '').trim();
    final combined = ('$first $last').trim();
    return combined.isEmpty ? (u.email ?? '—') : combined;
  }

  String _fileNameFromUrl(String? url) {
    if (url == null || url.trim().isEmpty) return 'Aucun CV';
    final uri = Uri.tryParse(url);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    final parts = url.split('/');
    return parts.isNotEmpty ? parts.last : url;
  }

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthController>();
    final planCtrl = context.watch<PlanController>();

    if (auth.initializing || auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: secondaryColor)),
      );
    }

    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 12,
        title: const Text(
          'Compte',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: const AppbarButton(icon: 'assets/icons/edit.svg'),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header: photo + name + quick action icons
                Row(
                  children: [
                    const ProfileImageView(),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName(auth),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: blackColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildIcon('assets/icons/call.svg'),
                              _buildIcon('assets/icons/message2.svg'),
                              // _buildIcon('assets/icons/location.svg'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Divider(thickness: 1, color: labelColor.withOpacity(0.3)),
                const SizedBox(height: 24),

                const SizedBox(height: 8),

                // ===== Mon abonnement =====
                const Text(
                  'Mon abonnement',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),

                if (planCtrl.loadingMyPlan)
                  _SubscriptionSkeleton()
                else
                  _SubscriptionCard(
                    current: planCtrl.myPlan,               // PlanWithExtras?
                    meta: planCtrl.mySubscription,          // SubscriptionMeta?
                    onChangePlan: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlansScreen()),
                      );
                    },
                    onRefresh: () => context.read<PlanController>().loadMyCurrentPlan(),
                  ),

                const SizedBox(height: 40),

                // ===== CV (optional) =====


                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _buildIcon(String icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: labelColor.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 12),
      child: Center(
        child: SvgPicture.asset(icon, color: blackColor),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final PlanWithExtras? current;
  final SubscriptionMeta? meta;
  final VoidCallback onChangePlan;
  final VoidCallback onRefresh;

  const _SubscriptionCard({
    Key? key,
    required this.current,
    required this.meta,
    required this.onChangePlan,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final planCtrl = context.watch<PlanController>();

    // All plans from catalog
    final all = planCtrl.plans;
    final currentId = planCtrl.myPlan?.plan.id;
    final metaForCurrent = planCtrl.mySubscription;

    // Build a card for every plan; add chips only for the current one
    final List<Widget> cards = all.map((pwe) {
      final p = pwe.plan;
      final isCurrent = p.id == currentId;

      return _PlanCard(
        planName: p.name,
        durationDays: p.durationDays,
        price: p.price,
        description: p.description,
        meta: isCurrent ? metaForCurrent : null, // chips only on current
        isCurrent: isCurrent,
        onSelect: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlanDetailsScreen(plan: p)),
          );
        },
      );
    }).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: labelColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cards.isEmpty) ...[
            const Text(
              'Aucun plan disponible',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const Text(
              'Plans disponibles',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor),
            ),
            const SizedBox(height: 12),
            ...cards, // <-- all plans rendered together
          ],

          const SizedBox(height: 12),
          // Single button after the whole list
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onChangePlan,
              child: const Text('Ajouter  d’abonnement'),
            ),
          ),
        ],
      ),
    );
  }



  Widget _chip(String label, String value) {
    return Chip(
      label: Text('$label: $value',
          style: const TextStyle(fontSize: 12, color: textColor)),
      backgroundColor: Colors.white,
      side: BorderSide(color: labelColor.withOpacity(.3)),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
    );
  }
}
class _PlanCard extends StatelessWidget {
  final String planName;
  final int durationDays;
  final double price;
  final String? description;
  final SubscriptionMeta? meta;      // only set for current plan
  final bool isCurrent;
  final VoidCallback onSelect;

  const _PlanCard({
    Key? key,
    required this.planName,
    required this.durationDays,
    required this.price,
    this.description,
    this.meta,
    required this.isCurrent,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: labelColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- plan info (same as your block) ---
          Text(
            planName,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Durée: $durationDays jours',
            style: const TextStyle(fontSize: 13, color: captionTextColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Prix: $price TND',
            style: const TextStyle(fontSize: 13, color: captionTextColor),
          ),

          // --- meta chips only if current ---
          if (meta != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _chip('Statut', meta!.status ?? '—'),
                // _chip('Paiement', meta!.paymentStatus ?? '—'),
                // _chip('Début',
                //     meta!.startDate?.toIso8601String().split('T').first ?? '—'),
                // _chip('Fin',
                //     meta!.endDate?.toIso8601String().split('T').first ?? '—'),
                _chip('Restant',
                    meta!.remainingDays != null ? '${meta!.remainingDays} j' : '—'),
              ],
            ),
          ],




        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    return Chip(
      label: Text('$label: $value',
          style: const TextStyle(fontSize: 12, color: textColor)),
      backgroundColor: Colors.white,
      side: BorderSide(color: labelColor.withOpacity(.3)),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
    );
  }
}

class _SubscriptionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // removed fixed height
      width: double.infinity,
      decoration: BoxDecoration(
        color: labelColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min, // <-- key: take only needed height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBar(),
          const SizedBox(height: 8),
          _shimmerBar(widthFactor: .7),
          const SizedBox(height: 8),
          _shimmerBar(widthFactor: .5),
          const SizedBox(height: 12), // <-- instead of Spacer()
          Row(
            children: [
              Expanded(child: _buttonGhost()),
              const SizedBox(width: 10),
              _smallCircle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerBar({double widthFactor = 1}) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buttonGhost() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _smallCircle() {
    return Container(
      height: 40,
      width: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.refresh, color: textColor),
    );
  }
}

