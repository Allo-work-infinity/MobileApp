// lib/modules/job_details/component/job_apply_bottom_sheet_body.dart
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/modules/apply_process/apply_process.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';
import 'package:job_finding/utils/utils.dart';

// read user + job model
import 'package:job_finding/modules/auth/controller/auth_controller.dart';
import 'package:job_finding/modules/home/model/job_offer.dart';

// ⬇️ contrôleur des candidatures
import 'package:job_finding/modules/applied_screen/controller/job_application_controller.dart';

class JobApplyBottomSheetBody extends StatefulWidget {
  final JobOffer offer;
  const JobApplyBottomSheetBody({Key? key, required this.offer}) : super(key: key);

  @override
  State<JobApplyBottomSheetBody> createState() => _JobApplyBottomSheetBodyState();
}

class _JobApplyBottomSheetBodyState extends State<JobApplyBottomSheetBody> {
  late final TextEditingController _nameC;
  late final TextEditingController _emailC;
  late final TextEditingController _phoneC;
  late final TextEditingController _cvC;
  late final TextEditingController _portfolioC;

  String _dialCode = '+216'; // par défaut TN
  String? _cvPath;           // chemin local du fichier CV sélectionné
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user;
    final first = (user?.firstName ?? '').trim();
    final last  = (user?.lastName ?? '').trim();
    final fullName = (('$first $last').trim().isEmpty ? (user?.email ?? '') : '$first $last').trim();

    _nameC      = TextEditingController(text: fullName);
    _emailC     = TextEditingController(text: user?.email ?? '');
    _phoneC     = TextEditingController(text: user?.phone ?? '');
    _cvC        = TextEditingController(); // affichera le nom du fichier
    _portfolioC = TextEditingController(text: user?.cvFileUrl ?? '');
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _cvC.dispose();
    _portfolioC.dispose();
    super.dispose();
  }

  String get _fullPhone => '${_dialCode.trim()} ${_phoneC.text.trim()}';

  Future<void> _pickCv() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      withData: false,
    );
    if (res != null && res.files.isNotEmpty) {
      final file = res.files.single;
      setState(() {
        _cvPath = file.path;
        _cvC.text = file.name;
      });
    }
  }

  void _clearCv() {
    setState(() {
      _cvPath = null;
      _cvC.clear();
    });
  }

  Future<void> _submit() async {
    final offerId = widget.offer.id;
    if (offerId == null) {
      _showSnack("Offre introuvable (id manquant).");
      return;
    }
    if (_emailC.text.trim().isEmpty) {
      _showSnack("Veuillez saisir votre e-mail.");
      return;
    }

    setState(() => _submitting = true);

    // petit loader modal pour la requête réseau
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: secondaryColor),
      ),
    );

    final jobAppCtrl = context.read<JobApplicationController>();
    File? cvFile;
    if (_cvPath != null && _cvPath!.isNotEmpty) {
      cvFile = File(_cvPath!);
    }

    // On passe le portfolio/URL dans additionalDocuments (si fourni)
    final List<String>? extras = _portfolioC.text.trim().isNotEmpty
        ? <String>[_portfolioC.text.trim()]
        : null;

    final created = await jobAppCtrl.applyToOffer(
      jobOfferId: offerId,
      cvFile: cvFile,
      cvFileUrl: null,              // si vous avez déjà un URL côté utilisateur
      additionalDocuments: extras,  // ex: portfolio
    );

    if (mounted) Navigator.of(context).pop(); // ferme le loader

    setState(() => _submitting = false);

    if (created != null) {
      // Succès → on peut afficher votre UI "ApplyProcessView" puis fermer la feuille
      if (!mounted) return;
      Utils.showCustomDialog(
        context,
        ApplyProcessView(
          onChanged: (value) {
            if (value == 10) {
              Navigator.pop(context); // ferme la boîte ApplyProcessView
              Navigator.pop(context); // ferme le bottom-sheet
              _showSnack("Candidature envoyée avec succès !");
            }
          },
        ),
      );
    } else {
      // Échec
      final err = jobAppCtrl.error ?? "Échec de l’envoi. Veuillez réessayer.";
      _showSnack(err);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.offer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        // protège des overflows quand le clavier est ouvert
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _header(o),
            const SizedBox(height: 24),

            // Nom
            const Text("Nom", style: TextStyle(fontSize: 16, color: paragraphColor)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameC,
              keyboardType: TextInputType.name,
              enabled: !_submitting,
              decoration: const InputDecoration(
                fillColor: fillColor,
                hintText: 'Nom complet',
              ),
            ),

            const SizedBox(height: 16),
            // Email
            const Text("E-mail", style: TextStyle(fontSize: 16, color: paragraphColor)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailC,
              keyboardType: TextInputType.emailAddress,
              enabled: !_submitting,
              decoration: const InputDecoration(
                fillColor: fillColor,
                hintText: 'Adresse e-mail',
              ),
            ),

            const SizedBox(height: 16),
            // Téléphone (code pays + numéro)
            const Text("Téléphone", style: TextStyle(fontSize: 16, color: paragraphColor)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  height: 56,
                  padding: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: fillColor,
                    border: Border.all(color: boarderColor),
                  ),
                  child: CountryCodePicker(
                    initialSelection: 'TN',
                    favorite: const ['+216', 'TN'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    onChanged: (code) {
                      setState(() {
                        _dialCode = code.dialCode ?? _dialCode;
                      });
                    },
                    enabled: !_submitting,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _phoneC,
                    keyboardType: TextInputType.phone,
                    enabled: !_submitting,
                    decoration: InputDecoration(
                      fillColor: fillColor,
                      hintText: 'Numéro de téléphone',
                      prefixText: '$_dialCode ',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // CV upload
            const Text("CV", style: TextStyle(fontSize: 16, color: paragraphColor)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cvC,
              readOnly: true,
              enabled: !_submitting,
              decoration: InputDecoration(
                fillColor: fillColor,
                hintText: "Sélectionner un fichier (PDF/DOC/DOCX)",
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_cvPath != null)
                      IconButton(
                        tooltip: 'Effacer',
                        icon: const Icon(Icons.clear, color: secondaryColor),
                        onPressed: _submitting ? null : _clearCv,
                      ),
                    IconButton(
                      tooltip: 'Téléverser',
                      icon: const Icon(Icons.upload_file, color: secondaryColor),
                      onPressed: _submitting ? null : _pickCv,
                    ),
                  ],
                ),
              ),
              onTap: _submitting ? null : _pickCv,
            ),

            const SizedBox(height: 16),
            // Portfolio / lien
            const Text("Portfolio / Lien", style: TextStyle(fontSize: 16, color: paragraphColor)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _portfolioC,
              keyboardType: TextInputType.url,
              enabled: !_submitting,
              decoration: const InputDecoration(
                hintText: "URL",
                fillColor: fillColor,
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                height: 18, width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text("Postuler"),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _header(JobOffer o) {
    final title = o.title ?? '—';
    final loc   = _fullLocation(o);
    final logo  = o.company?.logoUrl;

    return Row(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(24),
            image: (logo != null && logo.isNotEmpty)
                ? DecorationImage(image: NetworkImage(logo), fit: BoxFit.cover)
                : null,
          ),
          child: (logo == null || logo.isEmpty)
              ? Center(child: SvgPicture.asset(Kimages.uiLeadIcon))
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                loc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: paragraphColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fullLocation(JobOffer o) {
    final parts = <String>[
      (o.city ?? '').trim(),
      (o.governorate ?? '').trim(),
      (o.location ?? '').trim(),
    ].where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) return '—';

    final seen = <String>{};
    final unique = <String>[];
    for (final p in parts) {
      final k = p.toLowerCase();
      if (!seen.contains(k)) {
        seen.add(k);
        unique.add(p);
      }
    }
    return unique.join(', ');
  }
}
