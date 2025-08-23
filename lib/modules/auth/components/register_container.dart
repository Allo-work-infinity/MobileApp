import 'package:custom_check_box/custom_check_box.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:job_finding/modules/SubscriptionPlan/plans_screen.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/modules/auth/controller/auth_controller.dart';
import 'package:job_finding/modules/auth/components/have_an_account_or_not_view.dart';
import 'package:job_finding/modules/auth/components/social_button.dart';
import 'package:job_finding/router_name.dart';
import 'package:job_finding/utils/constants.dart';

class RegisterContainer extends StatefulWidget {
  const RegisterContainer({Key? key}) : super(key: key);

  @override
  State<RegisterContainer> createState() => _RegisterContainerState();
}

class _RegisterContainerState extends State<RegisterContainer> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();

  bool _agree = false;
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  String? _nameValidator(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Required';
    if (value.length > 100) return 'Max 100 caractères';
    return null;
  }

  String? _emailValidator(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'L\'e-mail est obligatoire';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
    if (!ok) return 'Entrez une adresse e-mail valide';
    return null;
  }

  String? _passwordValidator(String? v) {
    final value = (v ?? '');
    if (value.isEmpty) return 'Le mot de passe est requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    return null;
  }

  String? _passwordConfirmValidator(String? v) {
    if (v == null || v.isEmpty) return 'Confirmez votre mot de passe';
    if (v != _passwordCtrl.text) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  Future<void> _handleRegister(BuildContext context) async {
    final auth = context.read<AuthController>();
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez accepter les conditions pour continuer')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final ok = await auth.register(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      passwordConfirmation: _passwordConfirmCtrl.text,
      phone: null,
      city: null,
      governorate: null,
    );

    if (!mounted) return;

    if (ok) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PlansScreen()),
              (_) => false,
        );
    } else {
      final msg = auth.error ?? 'L\'inscription a échoué. Veuillez réessayer.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final loading = auth.loading;

    // Use a scroll view + add bottom padding equal to keyboard height
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 24, left: 20, right: 20, bottom: bottomInset + 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // allow shrinking
            children: [
              TextFormField(
                controller: _firstNameCtrl,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                validator: _nameValidator,
                decoration: const InputDecoration(
                  hintText: 'Prénom',
                  labelText: 'Prénom',
                ),
                enabled: !loading,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lastNameCtrl,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                validator: _nameValidator,
                decoration: const InputDecoration(
                  hintText: 'Nom de famille',
                  labelText: 'Nom de famille',
                ),
                enabled: !loading,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailCtrl,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
                decoration: const InputDecoration(
                  hintText: 'Votre e-mail',
                  labelText: 'Votre e-mail',
                ),
                enabled: !loading,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordCtrl,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.visiblePassword,
                validator: _passwordValidator,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  labelText: 'Mot de passe',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                enabled: !loading,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordConfirmCtrl,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                validator: _passwordConfirmValidator,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirmez le mot de passe',
                  labelText: 'Confirmez le mot de passe',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                enabled: !loading,
                onFieldSubmitted: (_) => _handleRegister(context),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomCheckBox(
                    value: _agree,
                    shouldShowBorder: true,
                    borderColor: blackColor,
                    checkedFillColor: _agree ? blackColor : primaryColor,
                    borderRadius: 4,
                    borderWidth: 2,
                    checkBoxSize: 16,
                    onChanged: (value) {
                      if (loading) return;
                      setState(() => _agree = value);
                    },
                  ),
                  Expanded(
                    child: RichText(
                      softWrap: true,
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: blackColor),
                        children: [
                          const TextSpan(
                            text: 'En créant un compte, j\'accepte la recherche d\'emploi',
                          ),
                          TextSpan(
                            text: 'terms & conditions',
                            recognizer: TapGestureRecognizer()..onTap = () {},
                            style: const TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'privacy policy',
                            recognizer: TapGestureRecognizer()..onTap = () {},
                            style: const TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (loading || !_agree) ? null : () => _handleRegister(context),
                  child: loading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text("Registre"),
                ),
              ),
              const SizedBox(height: 16),
              HaveAnAccountOrNotView(
                isLogin: false,
                onPressed: loading
                    ? null
                    : () => DefaultTabController.of(context)?.animateTo(0),
              ),
              const SizedBox(height: 24),
              // const SocialButton(text: 'Or Register with'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
