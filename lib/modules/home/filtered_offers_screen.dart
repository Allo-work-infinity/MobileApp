// lib/modules/home/filtered_offers_screen.dart
import 'package:flutter/material.dart';
import 'package:job_finding/modules/home/component/job_card_component.dart';
import 'package:job_finding/modules/job_details/job_details_screen.dart';
import 'package:provider/provider.dart';

import 'controller/job_offer_controller.dart';
import 'model/job_offer.dart';

import 'package:job_finding/utils/constants.dart';

class FilteredOffersScreen extends StatefulWidget {
  /// Filter key understood by your backend/controller:
  /// 'popular' | 'populer' | 'all' | 'open' | 'my-offer' | 'featured' | 'remote' | 'closed'
  /// OR a **category name** (e.g., "Mobile", "Développement", "IT Services", ...)
  final String filterKey;

  /// Optional page title for the top app bar
  final String? title;

  /// Optional extra query params to send to the API (e.g. {'city': 'Tunis'})
  final Map<String, dynamic>? params;

  const FilteredOffersScreen({
    Key? key,
    required this.filterKey,
    this.title,
    this.params,
  }) : super(key: key);

  @override
  State<FilteredOffersScreen> createState() => _FilteredOffersScreenState();
}

class _FilteredOffersScreenState extends State<FilteredOffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final c = context.read<JobOfferController>();
      await c.initByFilterOrCategory(
        filterOrCategory: widget.filterKey,
        params: widget.params,
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    final c = context.watch<JobOfferController>();
    final hasQ = ((widget.params?['q'])?.toString().trim().isNotEmpty ?? false);
    final titleText = widget.title ?? (hasQ ? 'Résultats' : _titleFromFilterOrCategory(widget.filterKey));

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: Colors.white,
        foregroundColor: secondaryColor,
        elevation: 0,
      ),
      body: Builder(
        builder: (_) {
          if (c.initializing || c.loading) {
            return const Center(child: CircularProgressIndicator(color: secondaryColor));
          }
          if (c.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  c.error!,
                  style: const TextStyle(color: secondaryColor),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (c.items.isEmpty) {
            return const Center(
              child: Text(
                "Aucune offre trouvée.",
                style: TextStyle(fontSize: 16, color: secondaryColor),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: c.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final o = c.items[i];
              return JobCardComponent(
                id: o.id,
                title: o.title ?? '—',
                address: _addr(o),
                tags: _tags(o),
                logoUrl: o.company?.logoUrl,
                salaryMin: o.salaryMin,
                salaryMax: o.salaryMax,
                currency: o.currency,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailsScreen(offer: o),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // -------- helpers --------

  String _titleFromFilterOrCategory(String key) {
    final k = key.trim();
    final lower = k.toLowerCase();
    switch (lower) {
      case 'all':
        return 'Toutes les offres';
      case 'popular':
      case 'populer':
        return 'Offres populaires';
      case 'my-offer':
        return 'Mes offres';
      case 'featured':
        return 'En vedette';
      case 'remote':
        return 'Télétravail';
      case 'closed':
        return 'Offres fermées';
      case 'open':
        return 'Offres ouvertes';
      default:
      // Treat as category name
        return 'Catégorie : ${_niceCase(k)}';
    }
  }

  String _niceCase(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _addr(JobOffer o) {
    final parts = <String>[];
    if ((o.city ?? '').trim().isNotEmpty) parts.add(o.city!.trim());
    if ((o.governorate ?? '').trim().isNotEmpty) parts.add(o.governorate!.trim());
    return parts.isEmpty ? '—' : parts.join(', ');
  }

  List<String> _tags(JobOffer o) {
    String _jobTypeTag(JobOffer o) {
      switch ((o.jobType ?? '').toLowerCase()) {
        case 'full_time':
          return 'Temps plein';
        case 'part_time':
          return 'Temps partiel';
        case 'contract':
          return 'Contrat';
        case 'internship':
          return 'Stage';
        case 'remote':
          return 'Télétravail';
        default:
          return 'Autre';
      }
    }

    String _expTag(JobOffer o) {
      switch ((o.experienceLevel ?? '').toLowerCase()) {
        case 'entry':
          return 'Débutant';
        case 'junior':
          return 'Junior';
        case 'mid':
          return 'Intermédiaire';
        case 'senior':
          return 'Senior';
        case 'lead':
          return 'Lead';
        default:
          return 'Autre';
      }
    }

    final tags = <String>[
      _jobTypeTag(o),
      _expTag(o),
      if (o.isFeatured) 'Featured',
    ];
    return tags;
  }
}
