// lib/modules/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/widget/profile_image_view.dart';

// Auth
import 'package:job_finding/modules/auth/controller/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _locationC = TextEditingController();

  bool _seededFromUser = false;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _locationC.dispose();
    super.dispose();
  }

  void _seedControllersFromUser(AuthController auth) {
    if (_seededFromUser) return;
    if (auth.initializing) return;
    final u = auth.user;
    if (u == null) return;

    final first = (u.firstName ?? '').trim();
    final last = (u.lastName ?? '').trim();
    final fullName = (('$first $last').trim().isEmpty ? (u.email ?? '') : '$first $last').trim();

    _nameC.text = fullName;
    _emailC.text = u.email ?? '';
    _phoneC.text = u.phone ?? '';
    // Essayez d'assembler une localisation simple depuis les champs
    final city = (u.city ?? '').trim();
    final gov = (u.governorate ?? '').trim();
    final address = (u.address ?? '').trim();
    final locParts = [address, city, gov].where((e) => e.isNotEmpty).toList();
    _locationC.text = locParts.isEmpty ? '' : locParts.join(', ');

    _seededFromUser = true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    // Pré-remplir quand les données user sont prêtes
    _seedControllersFromUser(auth);

    // États de chargement / non connecté
    if (auth.initializing || auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: secondaryColor)),
      );
    }
    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          leadingWidth: 0.0,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: labelColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 4),
                  margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
                  child: const Icon(Icons.arrow_back_ios, color: blackColor, size: 16),
                ),
              ),
              const Text(
                'Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        body: const Center(
          child: Text(
            "Veuillez vous connecter pour voir votre profil.",
            style: TextStyle(color: secondaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leadingWidth: 0.0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: labelColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.arrow_back_ios, color: blackColor, size: 16),
                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 4),
                margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
              ),
            ),
            const Text(
              'Modifier le profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const ProfileImageView(),
                  const SizedBox(height: 40),

                  // Nom
                  TextFormField(
                    controller: _nameC,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Votre nom',
                      labelText: 'Votre nom',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // E-mail
                  TextFormField(
                    controller: _emailC,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Votre e-mail',
                      labelText: 'Votre e-mail',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Téléphone
                  TextFormField(
                    controller: _phoneC,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Votre téléphone',
                      labelText: 'Votre téléphone',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Localisation
                  TextFormField(
                    controller: _locationC,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.streetAddress,
                    decoration: const InputDecoration(
                      hintText: 'Votre localisation',
                      labelText: 'Votre localisation',
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
            child: ElevatedButton(
              onPressed: () async  {
                final auth = context.read<AuthController>();
                final ok = await auth.updateProfile(
                  name: _nameC.text.trim(),
                  email: _emailC.text.trim(),
                  phone: _phoneC.text.trim(),
                  location: _locationC.text.trim(),
                );

                if (ok) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profil mis à jour.")),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erreur: ${auth.error}")),
                    );
                  }
                }
              },
              child: const Text("Enregistrer les modifications"),
            ),
          ),
        ],
      ),
    );
  }
}
