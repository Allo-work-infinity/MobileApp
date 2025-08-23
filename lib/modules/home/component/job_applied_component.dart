import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/modules/applied_screen/controller/job_application_controller.dart';
import 'package:job_finding/modules/applied_screen/model/job_application.dart';
import 'package:job_finding/modules/applied_screen/applied_screen.dart';
import 'package:job_finding/modules/search/component/job_card_component.dart';
import 'package:job_finding/utils/constants.dart';

class JobAppliedComponent extends StatefulWidget {
  const JobAppliedComponent({Key? key}) : super(key: key);

  @override
  State<JobAppliedComponent> createState() => _JobAppliedComponentState();
}

class _JobAppliedComponentState extends State<JobAppliedComponent> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    // Charge la liste au premier affichage (sans dupliquer si déjà chargé)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context.read<JobApplicationController>();
      if (!_bootstrapped && c.items.isEmpty && !c.initializing) {
        _bootstrapped = true;
        c.init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<JobApplicationController>();

    // Zone d'en-tête avec bouton "Voir tout"
    final header = Row(
      children: [
        const Expanded(
          child: Text(
            "Emplois auxquels vous avez postulé",
            style: TextStyle(fontSize: 20, height: 1.5, fontWeight: FontWeight.bold),
          ),
        ),
        c.items.isNotEmpty ? TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppliedScreen()),
            );
          },
          child: const Text("Voir tout"),
        ):SizedBox(),
      ],
    );

    // États de chargement / erreur / vide
    Widget content;
    if (c.initializing || c.loading) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: secondaryColor)),
      );
    } else if (c.error != null) {
      content = _errorBox(
        context,
        c.error!,
        onRetry: () => c.refresh(),
      );
    } else if (c.items.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "Vous n’avez pas encore postulé à un emploi.",
          style: TextStyle(fontSize: 14, color: labelColor),
        ),
      );
    } else {
      final visible = c.items.take(4).toList();
      content = Column(
        children: [
          ...List.generate(visible.length, (i) {
            final a = visible[i];
            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
              child: JobCardComponent(
                title: a.offerTitle ?? '—',
                address: a.company ?? '—',
                tags: _tagsFor(a),
              ),
            );
          }),
          if (c.items.length > 4) const SizedBox(height: 12),
          if (c.items.length > 4)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AppliedScreen()),
                  );
                },
                child: const Text("Voir toutes les candidatures"),
              ),
            ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  // Petit encart d'erreur avec action Réessayer
  Widget _errorBox(BuildContext context, String message, {VoidCallback? onRetry}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
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
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  // Construit les tags à afficher sur chaque carte
  List<String> _tagsFor(JobApplication a) {
    final tags = <String>[];
    tags.add(_statusLabel(a.status)); // statut lisible

    if (a.reviewed == true) tags.add('Révisée');

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
