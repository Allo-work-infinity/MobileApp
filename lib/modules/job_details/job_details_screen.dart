import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // ⬅️ add this

import 'package:job_finding/modules/job_details/component/job_custom_app_bar.dart';
import 'package:job_finding/modules/job_details/model/jobdetails_dymy_data.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';
import 'package:job_finding/widget/teg_text.dart';
import '../home/component/category_line_indicator_text.dart';

// Composants
import 'component/company_component.dart';
import 'component/job_apply_bottom_sheet_body.dart';
import 'component/populer_component.dart';
import 'component/requirements_component.dart';
import 'component/review_component.dart';

// Controller + modèle
import 'package:job_finding/modules/home/controller/job_offer_controller.dart';
import 'package:job_finding/modules/home/model/job_offer.dart';
import 'package:job_finding/modules/auth/controller/auth_controller.dart'; // ⬅️ to read user info

class JobDetailsScreen extends StatefulWidget {
  final JobOffer offer;
  const JobDetailsScreen({Key? key, required this.offer}) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  int _currentIndex = 0;
  bool _loadedOnce = false;

  // final List<Widget> _widgetList = const [
  //   PopulerComponent(description: widget.offer.description!),
  //   RequirementsComponent(requirementList: jobRequirementList),
  //   CompanyComponent(),
  //   // ReviewComponent(),
  // ];
  late final List<Widget> _widgetList;

  final List<String> jobPreviewList = const [
    "Description",
    // "Exigences",
    // "Entreprise",
    // "Avis",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.offer.id;
      if (!_loadedOnce && id != null) {
        _loadedOnce = true;
        context.read<JobOfferController>().show(id);
      }
    });
    _widgetList = [
      PopulerComponent(description: widget.offer.description ?? ''),
      // RequirementsComponent(requirementList: jobRequirementList),
      CompanyComponent(companyId: widget.offer.companyId ?? 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<JobOfferController>();

    final JobOffer displayed = () {
      final wid = widget.offer.id;
      if (wid != null) {
        if (c.selected?.id == wid) return c.selected!;
        final fromCache = c.items.cast<JobOffer?>()
            .firstWhere((o) => o?.id == wid, orElse: () => null);
        if (fromCache != null) return fromCache;
      }
      return widget.offer;
    }();

    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),
            JobCustomAppBar(
              text: "Détails de l’offre",
              bgColor: Colors.white.withOpacity(0.15),
            ),
            const SizedBox(height: 24),
            _buildDetailsCard(displayed),
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
                      itemCount: jobPreviewList.length,
                      itemBuilder: (_, index) => CategoryLineIndecatorText(
                        isCurrentItem: _currentIndex == index,
                        index: index,
                        text: jobPreviewList[index],
                        onTap: (int i) {
                          setState(() => _currentIndex = i);
                        },
                      ),
                    ),
                  ),
                  _widgetList[_currentIndex],
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
                // ⬇️ now opens WhatsApp with a pro message in FR
                onPressed: _contactViaWhatsApp,
                child: const Text("Postuler"),
              ),
            ),
            // const SizedBox(width: 10),
            // ElevatedButton(
            //   onPressed: () {},
            //   style: ElevatedButton.styleFrom(
            //     minimumSize: const Size(56, 56),
            //     maximumSize: const Size(56, 56),
            //   ),
            //   child: SvgPicture.asset(
            //     Kimages.messageIcon,
            //     height: 24,
            //     width: 24,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // --- WhatsApp ---

  /// Change this to the recruiter/company WhatsApp number (international format).
  /// WhatsApp prefers digits only (no +, spaces or dashes) in wa.me links.
  static const String _defaultCompanyWhatsApp = '+21627541269';

  Future<void> _contactViaWhatsApp() async {
    final offer = widget.offer;
    final auth = context.read<AuthController>().user;

    final company = offer.company?.name ?? 'Service RH';
    final title   = offer.title ?? '—';
    final ref     = (offer.reference ?? '—').toString();

    final name  = (auth?.name.isNotEmpty ?? false) ? auth!.name : 'Candidat·e';
    final email = auth?.email ?? '—';
    final phone = auth?.phone ?? '—';

    final msg = '''
Bonjour $company,

Je me permets de vous contacter concernant ma candidature au poste « $title » (réf. $ref).
Je souhaiterais convenir d’un entretien afin d’échanger sur ma candidature.

Mes disponibilités : à votre convenance cette semaine.

Coordonnées :
• Nom : $name
• E-mail : $email
• Téléphone : $phone

Merci d’avance pour votre retour.
Cordialement,
$name
''';

    final encoded = Uri.encodeComponent(msg);
    final phoneDigits = _digitsOnly(_defaultCompanyWhatsApp);

    if (phoneDigits.isEmpty) {
      _toast('Numéro WhatsApp de l’entreprise manquant.');
      return;
    }

    // Try the app scheme first
    const kDefaultWhatsApp = '+21650123456';
    final appUri = Uri.parse('whatsapp://send?phone=$phoneDigits&text=$encoded');
    if (await canLaunchUrl(appUri)) {
      final ok = await launchUrl(appUri, mode: LaunchMode.externalApplication);
      if (!ok) _toast("Impossible d’ouvrir WhatsApp.");
      return;
    }

    // Fallback to web (opens browser/WhatsApp)
    final webUri = Uri.parse('https://wa.me/$phoneDigits?text=$encoded');
    if (await canLaunchUrl(webUri)) {
      final ok = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (!ok) _toast("Impossible d’ouvrir WhatsApp.");
      return;
    }

    _toast("WhatsApp n’est pas disponible sur cet appareil.");
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m)),
    );
  }

  // === SECTIONS UI ===

  Padding _buildDetailsCard(JobOffer o) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _DynamicHeader(offer: o),
          const SizedBox(height: 22),
          _buildTagAndSalary(o),
        ],
      ),
    );
  }

  Row _buildTagAndSalary(JobOffer o) {
    final tags = <String>[
      _formatJobType(o.jobType),
      if ((o.city ?? o.location ?? '').isNotEmpty) (o.city ?? o.location!) ,
      if ((o.experienceLevel ?? '').isNotEmpty) _formatExperience(o.experienceLevel),
      if (o.remoteAllowed) 'Télétravail',
    ].where((e) => e.trim().isNotEmpty).toList();

    final salary = _formatSalary(o.salaryMin, o.salaryMax, o.currency);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...tags.take(3).map(
              (e) => TagText(
            text: e,
            textColor: Colors.white,
            bgColor: Colors.white.withOpacity(.15),
          ),
        ),
        const Spacer(),
        if (salary != null)
          Text.rich(
            TextSpan(
              text: salary.amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              children: [
                if (salary.suffix != null)
                  TextSpan(
                    text: salary.suffix!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatJobType(String? t) {
    switch ((t ?? '').toLowerCase()) {
      case 'full_time': return 'Temps plein';
      case 'part_time': return 'Temps partiel';
      case 'contract':  return 'Contrat';
      case 'internship':return 'Stage';
      case 'remote':    return 'Télétravail';
      default:          return (t ?? '').isEmpty ? 'Autre' : t!;
    }
  }

  String _formatExperience(String? t) {
    switch ((t ?? '').toLowerCase()) {
      case 'entry':  return 'Débutant';
      case 'junior': return 'Junior';
      case 'mid':    return 'Intermédiaire';
      case 'senior': return 'Senior';
      case 'lead':   return 'Lead';
      default:       return (t ?? '').isEmpty ? 'Autre' : t!;
    }
  }

  _SalaryText? _formatSalary(double? min, double? max, String? currency) {
    if (min == null && max == null) return null;
    final cur = (currency ?? 'TND').toUpperCase();
    String main;
    if (min != null && max != null) {
      main = '${_trimZero(min)}–${_trimZero(max)} $cur';
    } else if (min != null) {
      main = '≥ ${_trimZero(min)} $cur';
    } else {
      main = '≤ ${_trimZero(max!)} $cur';
    }
    return _SalaryText(amount: main, suffix: null);
  }

  String _trimZero(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  // You still keep the sheet if you want to reuse it elsewhere.
  void _showSheet() {
    const double headerRadius = 36;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(headerRadius),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: boarderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Formulaire de candidature",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: boarderColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: JobApplyBottomSheetBody(offer: widget.offer),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DynamicHeader extends StatelessWidget {
  final JobOffer offer;
  const _DynamicHeader({required this.offer});

  @override
  Widget build(BuildContext context) {
    final companyName = offer.company?.name ?? '—';
    final title = offer.title ?? '—';
    final logoUrl = offer.company?.logoUrl;

    return Container(
      padding: const EdgeInsets.all(18),
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
              image: logoUrl != null && logoUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: (logoUrl == null || logoUrl.isEmpty)
                ? const Icon(Icons.business, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryText {
  final String amount;
  final String? suffix;
  _SalaryText({required this.amount, this.suffix});
}
