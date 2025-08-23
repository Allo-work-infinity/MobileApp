import 'package:flutter/material.dart';
import 'package:job_finding/modules/applied_screen/controller/job_application_controller.dart';
import 'package:job_finding/modules/applied_screen/model/job_application.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/modules/search/component/search_custom_app_bar.dart';
import 'package:job_finding/modules/search/component/custom_toggle_button.dart';
import 'package:job_finding/modules/search/component/job_card_component.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';



class AppliedScreen extends StatefulWidget {
  const AppliedScreen({Key? key}) : super(key: key);

  @override
  State<AppliedScreen> createState() => _AppliedScreenState();
}

class _AppliedScreenState extends State<AppliedScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // First fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobApplicationController>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<JobApplicationController>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const SearchCustomAppBar(text: 'Mes candidatures', isBackShow: false),
            const SizedBox(height: 24),

            // CustomToggleButton(
            //   onTap: (int v) async {
            //     setState(() => _currentIndex = v);
            //     // 0 = Applied (all), 1 = Interviews (server-side: under_review)
            //     if (v == 0) {
            //       await context.read<JobApplicationController>().setStatus(null);
            //     } else {
            //       await context
            //           .read<JobApplicationController>()
            //           .setStatus('under_review');
            //     }
            //   },
            //   label: const ["Candidature envoyée"],
            //   isFirst: _currentIndex,1
            // ),

            const SizedBox(height: 16),

            // Loading & error states
            if (c.initializing || c.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: secondaryColor),
                ),
              )
            else if (c.error != null)
              _errorBox(context, c.error!, onRetry: () {
                c.refresh();
              })
            else
              ...[
                // Header count
                Text(
                  "${c.totalCount.toString().padLeft(2, '0')} ${_currentIndex == 0 ? "Candidatures trouvées" : "Entretiens trouvés"}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // List of applications
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: c.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final a = c.items[i];
                    return JobCardComponent(
                      // We only have offer title + company in list payload,
                      // so map them to your existing card props.
                      title: a.offerTitle ?? '—',
                      address: a.company ?? '—',
                      tags: _tagsFor(a),
                    );
                  },
                ),

                // Load more (if server paginates)
                if (c.hasMore) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: c.loadingMore ? null : () => c.loadMore(),
                    child: c.loadingMore
                        ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : const Text("Charger plus"),
                  ),
                ],
                const SizedBox(height: 16),
              ],

            // Interviews tab empty-state (local UI, not server)
            if (!c.loading && !c.initializing && c.items.isEmpty && _currentIndex == 1)
              _notAppliedList(),
          ],
        ),
      ),
    );
  }

  // Fallback empty/interview content
  Widget _notAppliedList() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Image.asset(Kimages.noInterviewImage),
        const SizedBox(height: 24),
        const Text(
          "No Schedule",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          "Il n'y a pas encore d'entretiens d'embauche prévus",
          style: TextStyle(fontSize: 14, color: labelColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Small error box with retry
  Widget _errorBox(BuildContext context, String message, {VoidCallback? onRetry}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boarderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(color: secondaryColor),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  // Build tag chips for each application row
  List<String> _tagsFor(JobApplication a) {
    final tags = <String>[];
    // Human-readable status
    tags.add(_statusLabel(a.status));

    // Reviewed?
    if (a.reviewed == true) tags.add('Révisé');

    // Applied date (YYYY-MM-DD)
    final applied = a.appliedAt;
    if (applied != null) {
      final y = applied.year.toString().padLeft(4, '0');
      final m = applied.month.toString().padLeft(2, '0');
      final d = applied.day.toString().padLeft(2, '0');
      tags.add('$y-$m-$d');
    }

    return tags;
  }

  String _statusLabel(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'submitted':
        return 'Envoyée';
      case 'under_review':
        return "En cours d'examen";
      case 'shortlisted':
        return 'Présélectionnée';
      case 'accepted':
        return 'Acceptée';
      case 'rejected':
        return 'Refusée';
      default:
        return 'Inconnu';
    }

  }
}
