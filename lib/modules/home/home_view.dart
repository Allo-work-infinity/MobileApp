// lib/modules/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart';
import 'package:job_finding/modules/home/filtered_offers_screen.dart';
import 'package:job_finding/modules/job_details/job_details_screen.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/modules/home/model/job_offer.dart';
import 'package:job_finding/modules/home/controller/category_controller.dart';
import 'package:job_finding/modules/home/controller/job_offer_controller.dart';

import 'package:job_finding/modules/home/component/job_applied_component.dart';
import 'package:job_finding/modules/options/option_view.dart';
import 'package:job_finding/router_name.dart';
import 'package:job_finding/utils/utils.dart';
import 'component/category_component.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';
import 'package:job_finding/modules/usage/cooldown_screen.dart';
import 'component/tag_component.dart';
import 'model/category_cart_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _sentToCooldown = false;
  final _searchCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();

    // Kick off loads once the widget is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Always init popular offers once; controller handles re-entrancy.
      context.read<JobOfferController>().init(filter: 'popular');


      // Init categories too (safe to call again).
      context.read<CategoryController>().init();
    });
  }
  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // 1) Get dynamic names from category controller (fallback keeps UI stable)
    final base = _categoryNames(context, fallback: const ['Populaire']);

    // 2) Prepend "Toute" as the first chip (avoid duplicates)
    final categorys = <String>['Toute', ...base.where((e) => e.toLowerCase() != 'toute')];

    // 3) Read popular job offers from JobOfferController
    final jobCtrl = context.watch<JobOfferController>();
    final loadingPopular = jobCtrl.initializing || jobCtrl.loading;
    final popularItems = jobCtrl.items; // loaded with filter='popular'
    final popularCards = _mapOffersToCards(popularItems);

    if (jobCtrl.cooldownActive && !_sentToCooldown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _sentToCooldown = true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CooldownScreen()),
        );
      });
    }
    return SafeArea(
      child: ListView(
        children: [
          _buildAppbar(context),
          _getPaddingChild(
            child: const Text(
              "Rechercher, Trouver et Postuler",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchField(context),
          const SizedBox(height: 24),

          // 👉 Tag chips now show: ["Toute", ...api categories]
          TagListComponent(item: categorys),

          const SizedBox(height: 40),

          // 👉 Popular jobs section powered by API
          if (loadingPopular)
            _getPaddingChild(
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: secondaryColor),
                ),
              ),
            )
          else if ((jobCtrl.error ?? '').isNotEmpty)
            _getPaddingChild(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  jobCtrl.error!,
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
              ),
            )
          else if (popularCards.isEmpty)
              _getPaddingChild(
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    "Aucune offre populaire pour le moment.",
                    style: TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ),
              )
            else
              CategoryComponent(
                catList: const ['Populaires'],
                categoryCartList: popularCards,
              ),

          const SizedBox(height: 20),
          // const JobAppliedComponent(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Pull names from CategoryController; use fallback while loading/empty/errors.
  static List<String> _categoryNames(BuildContext context, {List<String> fallback = const []}) {
    final c = context.watch<CategoryController>();
    if (c.initializing || c.loading) return fallback;
    if (c.error != null) return fallback;

    final names = c.categories
        .map((e) => (e.name ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return names.isNotEmpty ? names : fallback;
  }

  /// Map API job offers to your demo card UI model.
  // lib/modules/home/home_view.dart
// make sure this import exists

  List<CategoryCartModel> _mapOffersToCards(List<JobOffer> offers) {
    const colors = <Color>[
      Color(0xff4FAA89),
      Color.fromARGB(255, 109, 108, 108),
      Color.fromARGB(255, 247, 224, 224),
    ];

    String _addr(JobOffer o) {
      final parts = <String>[];
      if ((o.city ?? '').trim().isNotEmpty) parts.add(o.city!.trim());
      if ((o.governorate ?? '').trim().isNotEmpty) parts.add(o.governorate!.trim());
      return parts.isEmpty ? '—' : parts.join(', ');
    }

    String _jobTypeTag(JobOffer o) {
      switch ((o.jobType ?? '').toLowerCase()) {
        case 'full_time':  return 'À temps plein';
        case 'part_time':  return 'Temps partiel';
        case 'contract':   return 'Contracter';
        case 'internship': return 'Stage';
        case 'remote':     return 'Télétravail';
        default:           return 'Autre';
      }
    }

    String _expTag(JobOffer o) {
      switch ((o.experienceLevel ?? '').toLowerCase()) {
        case 'entry':  return 'Entrée';
        case 'junior': return 'Junior';
        case 'mid':    return 'Milieu';
        case 'senior': return 'Senior';
        case 'lead':   return 'chef';
        default:       return 'Autre';
      }
    }

    return List<CategoryCartModel>.generate(offers.length, (i) {
      final o = offers[i];

      final tags = <String>[
        _jobTypeTag(o),
        _expTag(o),
        if (o.isFeatured) 'Featured',
      ];

      final logo = (o.company?.logoUrl ?? '').trim();
      final isNet = logo.startsWith('http://') || logo.startsWith('https://');

      final double price = (o.salaryMin ?? o.salaryMax ?? 0).toDouble();
      final String safeTitle = o.title ?? '—';

      return CategoryCartModel(
        id: o.id ?? i,
        image: isNet ? logo : Kimages.shopifyIcon, // fall back to asset if no URL
        imageIsNetwork: isNet,                      // tell the card how to load it
        price: price,
        address: _addr(o),
        title: safeTitle,
        tags: tags,
        color: colors[i % colors.length],

        // 👇 Tap navigates with the full JobOffer
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobDetailsScreen(offer: o),
            ),
          );
        },
      );
    });
  }


  Widget _buildSearchField(context) {
    return _getPaddingChild(
      child: TextFormField(
        controller: _searchCtrl,
        style: const TextStyle(color: secondaryColor),
        textInputAction: TextInputAction.search,
        onFieldSubmitted: _onSearchSubmit,      // <— ENTER/GO on keyboard
        decoration: InputDecoration(
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: boarderColor),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: boarderColor),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: boarderColor),
          ),
          fillColor: Colors.transparent,
          filled: true,
          hintText: "Rechercher ici…",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIconConstraints: const BoxConstraints(maxHeight: 40, maxWidth: 40),
          suffixIconConstraints: const BoxConstraints(maxHeight: 40, maxWidth: 40),
          prefixIcon: Container(
            height: 24,
            width: 24,
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: secondaryColor,
              shape: BoxShape.circle,
            ),
          ),
          suffixIconColor: secondaryColor,
          suffixIcon: IconButton(
            tooltip: 'Rechercher',
            onPressed: () => _onSearchSubmit(_searchCtrl.text), // <— filter icon click
            icon: SvgPicture.asset(
              Kimages.filterIcon,
              height: 18,
              width: 18,
              color: secondaryColor,
            ),
          ),
          hintStyle: const TextStyle(color: secondaryColor),
        ),
      ),
    );
  }

  void _onSearchSubmit(String text) {
    final q = text.trim();
    if (q.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilteredOffersScreen(
          filterKey: 'all',           // use server filter
          title: null,                // ← IMPORTANT: don't pass "Résultats"
          params: {'q': q},           // backend receives ?q=...
        ),
      ),
    );
  }



  Widget _getPaddingChild({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: child,
    );
  }

  Widget _buildAppbar(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Utils.showCustomDialog(
                context,
                const OptionView(),
                onTap: () => Navigator.pop(context),
              );
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: boarderColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: SvgPicture.asset(Kimages.drawerIcon)),
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.pushNamed(context, Routes.notificationScreen);
          //   },
          //   child: Badge(
          //     badgeContent: const Text(''),
          //     position: BadgePosition.topEnd(end: 0, top: -10),
          //     child: SvgPicture.asset(
          //       Kimages.notificationIcon,
          //       height: 24,
          //       width: 24,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
