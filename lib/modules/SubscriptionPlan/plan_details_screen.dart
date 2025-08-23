// lib/modules/SubscriptionPlan/plan_details_screen.dart
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/modules/SubscriptionPlan/controller/payment_controller.dart';
import 'package:job_finding/modules/SubscriptionPlan/payment_screen.dart';
import 'package:job_finding/modules/SubscriptionPlan/select_payment_method_screen.dart';
import 'package:provider/provider.dart';

import 'controller/plan_controller.dart';
import 'model/subscription_plan.dart';
import 'package:job_finding/router_name.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';
import 'package:job_finding/widget/teg_text.dart';
import 'package:job_finding/modules/job_details/component/job_custom_app_bar.dart';
import 'package:job_finding/modules/home/component/category_line_indicator_text.dart';
import '../auth/controller/auth_controller.dart';

class PlanDetailsScreen extends StatefulWidget {
  final SubscriptionPlan plan;
  const PlanDetailsScreen({Key? key, required this.plan}) : super(key: key);

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  int _currentIndex = 0;
  bool _buying = false;

  List<String> get _tabs {
    final hasDesc = (widget.plan.description ?? '').trim().isNotEmpty;
    final hasFeatures = widget.plan.features.isNotEmpty;
    final items = <String>[];
    if (hasDesc) items.add('Aperçu');
    if (hasFeatures) items.add('Caractéristiques');
    if (items.isEmpty) items.add('Aperçu');
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),
            JobCustomAppBar(
              text: widget.plan.name,
              bgColor: Colors.white.withOpacity(0.15),
            ),
            const SizedBox(height: 24),
            _buildDetailsCard(),
            const SizedBox(height: 30),
            Container(
              constraints: const BoxConstraints(minHeight: 500),
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 30,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      itemBuilder: (_, index) => CategoryLineIndecatorText(
                        isCurrentItem: _currentIndex == index,
                        index: index,
                        text: _tabs[index],
                        onTap: (int i) {
                          setState(() {
                            _currentIndex = i;
                          });
                        },
                      ),
                    ),
                  ),
                  _buildTabBody(),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Flexible(
              child: ElevatedButton(
                onPressed: () {
                  final id = widget.plan.id;
                  if (id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Plan ID manquant')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectPaymentMethodScreen(
                        subscriptionId: id,
                        amount: widget.plan.price,
                        currency: 'TND', // ou la devise de ton plan si dispo
                        description: 'Subscription: ${widget.plan.name}',
                      ),
                    ),
                  );
                },
                child: const Text("Acheter un plan"),
              ),
            ),
          ],
        ),
      ),

    );
  }
  Future<String> _getKonnectToken(BuildContext context) async {
    // TODO: Integrate your Konnect tokenization step here (card form / SDK).
    // Must return the token string that your Laravel endpoint expects as "token".
    // For now, throw if you haven't wired it:
    // throw UnimplementedError('Provide Konnect token here');
    return 'KONNECT_TOKEN_FROM_UI';
  }

  Widget _buildTabBody() {
    final tab = _tabs[_currentIndex];
    if (tab == 'Features') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            ...widget.plan.features.map(
                  (f) => Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: boarderColor.withOpacity(.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            if (widget.plan.features.isEmpty)
              const Text("No features listed.", style: TextStyle(color: Colors.black54)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _miniInfoTile("Duration", "${widget.plan.durationDays} jours"),
          const SizedBox(height: 10),
          _miniInfoTile("Price", "${widget.plan.price} TND"),
          const SizedBox(height: 16),
          if ((widget.plan.description ?? '').trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: boarderColor.withOpacity(.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.plan.description!.trim(),
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
              ),
            ),
          if ((widget.plan.description ?? '').trim().isEmpty)
            const Text("Aucune description fournie.", style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _miniInfoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: boarderColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Padding _buildDetailsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _PlanHeader(name: widget.plan.name),
          const SizedBox(height: 22),
          _buildTagAndPrice(),
        ],
      ),
    );
  }

  Row _buildTagAndPrice() {
    return Row(
      children: [
        // TagText(
        //   text: "${widget.plan.durationDays} days",
        //   textColor: Colors.white,
        //   bgColor: Colors.white.withOpacity(.15),
        // ),
        // TagText(
        //   text: "Plan",
        //   textColor: Colors.white,
        //   bgColor: Colors.white.withOpacity(.15),
        // ),
        // const Spacer(),
        // Text.rich(
        //   TextSpan(
        //     text: "${widget.plan.price}",
        //     style: const TextStyle(
        //       fontSize: 16,
        //       fontWeight: FontWeight.bold,
        //       color: Colors.white,
        //     ),
        //     children: [
        //       TextSpan(
        //         text: " TND",
        //         style: TextStyle(
        //           fontSize: 12,
        //           color: Colors.white.withOpacity(0.8),
        //           fontWeight: FontWeight.w400,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  void _showBuySheet() {
    final headerHeight = 72.0;
    final maxHeight = .8;
    showStickyFlexibleBottomSheet<void>(
      bodyBuilder: (context, offset) {
        return SliverChildListDelegate([
          _BuySheetBody(
            plan: widget.plan,
            buying: _buying,
            onConfirm: _subscribeNow,
          ),
        ]);
      },
      anchors: [.2, 0.5, maxHeight],
      minHeight: 0,
      initHeight: 0.5,
      maxHeight: maxHeight,
      headerHeight: headerHeight,
      context: context,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(headerHeight / 2)),
      ),
      headerBuilder: (context, offset) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: headerHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(offset == maxHeight ? 0 : headerHeight / 2),
              topRight: Radius.circular(offset == maxHeight ? 0 : headerHeight / 2),
            ),
          ),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Acheter un plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: boarderColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _subscribeNow() async {
    if (_buying) return;
    setState(() => _buying = true);
    final nav = Navigator.of(context);
    try {
      final planId = widget.plan.id;
      if (planId == null) {
        throw Exception("This plan has no ID.");
      }
      await context.read<PlanController>().subscribeToPlan(planId);
      await context.read<AuthController>().refreshUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Abonné à ${widget.plan.name}!")),
      );
      nav.pushNamedAndRemoveUntil(Routes.home, (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }
}

class _PlanHeader extends StatelessWidget {
  final String name;
  const _PlanHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  "Subscription Plan",
                  style: TextStyle(color: Colors.white.withOpacity(.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuySheetBody extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool buying;
  final VoidCallback onConfirm;

  const _BuySheetBody({
    Key? key,
    required this.plan,
    required this.buying,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _priceRow("${plan.price} TND", "${plan.durationDays} days"),
          const SizedBox(height: 16),
          if ((plan.description ?? '').trim().isNotEmpty)
            Text(plan.description!.trim(),
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
          if (plan.features.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text("What you’ll get", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...plan.features.take(6).map(
                  (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: buying ? null : onConfirm,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: buying
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text("Confirm • ${plan.price} TND"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String price, String duration) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: boarderColor.withOpacity(.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule, size: 16),
              const SizedBox(width: 6),
              Text(duration, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const Spacer(),
        Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
