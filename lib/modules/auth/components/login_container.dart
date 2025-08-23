import 'package:auto_size_text/auto_size_text.dart';
import 'package:custom_check_box/custom_check_box.dart';
import 'package:flutter/material.dart';
import 'package:job_finding/modules/SubscriptionPlan/plans_screen.dart';
import 'package:provider/provider.dart';

import 'package:job_finding/modules/auth/controller/auth_controller.dart';
import 'package:job_finding/modules/auth/components/have_an_account_or_not_view.dart';
import 'package:job_finding/modules/auth/components/social_button.dart';
import 'package:job_finding/router_name.dart';
import 'package:job_finding/utils/constants.dart';

class LoginContainer extends StatefulWidget {
  const LoginContainer({Key? key}) : super(key: key);

  @override
  State<LoginContainer> createState() => _LoginContainerState();
}

class _LoginContainerState extends State<LoginContainer> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
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
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  Future<void> _handleLogin(BuildContext context) async {
    final auth = context.read<AuthController>();
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      final user = auth.user; // assumes AuthController exposes the logged-in user
      final hasSub = user?.hasActiveSubscription == true;

      if (hasSub) {
        // User already subscribed → go home
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false);
      } else {
        // No active subscription → go to plans
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PlansScreen()),
              (_) => false,
        );
        // If you have a named route instead, use:
        // Navigator.pushNamedAndRemoveUntil(context, Routes.plans, (_) => false);
      }
    } else {
      final msg = auth.error ?? 'Échec de la connexion. Veuillez réessayer.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final loading = auth.loading;

    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
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
              textInputAction: TextInputAction.done,
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
              onFieldSubmitted: (_) => _handleLogin(context),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // ✅ Checkbox
                    CustomCheckBox(
                      value: _rememberMe,
                      shouldShowBorder: true,
                      borderColor: blackColor,
                      checkedFillColor: _rememberMe ? blackColor : primaryColor,
                      borderRadius: 4,
                      borderWidth: 2,
                      checkBoxSize: 16,
                      onChanged: (value) {
                        if (loading) return;
                        setState(() => _rememberMe = value);
                      },
                    ),
                    const SizedBox(width: 8),

                    // ✅ Let text take remaining width, avoid overflow
                    const Expanded(
                      child: AutoSizeText(
                        'Souviens-toi de moi',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: blackColor,
                        ),
                        maxFontSize: 16,
                        minFontSize: 14,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ✅ Put "forgot password" under it, aligned to the right
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: loading ? null : () {
                      // TODO: implement forgot password
                    },
                    child: const AutoSizeText(
                      'Mot de passe oublié?',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: secondaryColor,
                      ),
                      maxFontSize: 16,
                      minFontSize: 14,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : () => _handleLogin(context),
                child: loading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Se connecter"),
              ),
            ),
            const SizedBox(height: 16),
            // Switch to Register tab instead of undefined Routes.signup
            HaveAnAccountOrNotView(
              isLogin: true,
              onPressed: loading
                  ? null
                  : () => DefaultTabController.of(context)?.animateTo(1),
            ),
            const Spacer(),
            // const SocialButton(text: 'Or log in with'),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
