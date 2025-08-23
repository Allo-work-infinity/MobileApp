import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/modules/SubscriptionPlan/plan_details_screen.dart';
import 'package:job_finding/modules/SubscriptionPlan/repository/subscription_plan_repository.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';
import 'package:job_finding/router_name.dart';

import 'controller/plan_controller.dart';
import 'model/subscription_plan.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({Key? key}) : super(key: key);

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  void initState() {
    super.initState();
    // Load first page (or non-paginated if you prefer)
    // ignore: avoid_types_on_closure_parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanController>().loadFirstPage(); // or .loadPlans()
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PlanController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plans d\'abonnement',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          // Header graphic (keeps same vibe as ContinueAsScreen)
          Expanded(
            flex: 2,
            child: Center(child: SvgPicture.asset(Kimages.logoBlackIcon)),
          ),

          // Content
          Expanded(
            flex: 5,
            child: RefreshIndicator(
              onRefresh: () => ctrl.refresh(paginated: true),
              child: ctrl.loading && ctrl.pageItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ctrl.error != null
                  ? _ErrorView(
                message: ctrl.error!,
                onRetry: () => ctrl.loadFirstPage(),
              )
                  : ListView.builder(
                padding:
                const EdgeInsets.only(bottom: 24, top: 8),
                itemCount: ctrl.pageItems.length +
                    (ctrl.currentPage < ctrl.lastPage ? 1 : 0),
                itemBuilder: (context, index) {
                  // Load-more footer
                  if (index == ctrl.pageItems.length) {
                    return _LoadMoreTile(
                      loadingMore: ctrl.loadingMore,
                      canLoadMore:
                      ctrl.currentPage < ctrl.lastPage,
                      onLoadMore: () => ctrl.loadMore(),
                    );
                  }

                  final PlanWithExtras item =
                  ctrl.pageItems[index];
                  final SubscriptionPlan p = item.plan;

                  // Alternate the “reverse” styling for variety
                  final reverse = index.isOdd;

                  return PlanCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlanDetailsScreen(plan: p),
                        ),
                      );
                    },

                    title: p.name,
                    caption:
                    '${p.durationDays} jours • ${_formatPrice(p.price)}',
                    // Show the first 2 features as a sub-caption
                    subCaption: (p.features.isNotEmpty)
                        ? '• ${p.features.take(2).join(' • ')}'
                        : null,
                    icon: reverse
                        ? Kimages.arrowBlack
                        : Kimages.arrowWhite,
                    backgroundColor: reverse
                        ? circleColor.withOpacity(0.4)
                        : blackColor,
                    reverse: reverse,
                    boxShadow: reverse
                        ? null
                        : [
                      BoxShadow(
                        color: blackColor.withOpacity(0.4),
                        offset: const Offset(4, 8),
                        blurRadius: 20,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),

    );
  }

  String _formatPrice(double v) {
    // keep simple: show 3 decimals like backend decimal:3
    return '${(v * 1000).round() / 1000.0} TND';
  }


}

/// Card styled like your ContinueButton, but configurable for plans
class PlanCard extends StatelessWidget {
  const PlanCard({
    Key? key,
    required this.onTap,
    required this.title,
    required this.caption,
    required this.icon,
    required this.backgroundColor,
    this.reverse = false,
    this.boxShadow,
    this.subCaption,
  }) : super(key: key);

  final VoidCallback onTap;
  final String title;
  final String caption;
  final String? subCaption;
  final String icon;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: boxShadow,
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: reverse ? blackColor : primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    caption,
                    style: TextStyle(
                      fontSize: 14,
                      color: reverse
                          ? blackColor.withOpacity(0.8)
                          : primaryColor.withOpacity(0.9),
                    ),
                  ),
                  if (subCaption != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subCaption!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: reverse
                            ? blackColor.withOpacity(0.7)
                            : primaryColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              right: -8,
              child: SvgPicture.asset(
                Kimages.arrowVector,
                color: labelColor.withOpacity(0.5),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SvgPicture.asset(icon),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreTile extends StatelessWidget {
  const _LoadMoreTile({
    Key? key,
    required this.loadingMore,
    required this.canLoadMore,
    required this.onLoadMore,
  }) : super(key: key);

  final bool loadingMore;
  final bool canLoadMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!canLoadMore) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: loadingMore ? null : onLoadMore,
          child: loadingMore
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Load more'),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({Key? key, required this.message, required this.onRetry})
      : super(key: key);

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Error',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(message),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
