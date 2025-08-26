import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/modules/auth/auth_screen.dart';
import 'package:job_finding/modules/profile/profile_screen.dart';
import 'package:provider/provider.dart';                    // NEW
import 'package:job_finding/modules/auth/controller/auth_controller.dart'; // NEW
import 'package:job_finding/router_name.dart';

class OptionView extends StatelessWidget {
  const OptionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>(); // watch loading/error state

    return Column(
      children: [
        const Expanded(flex: 1, child: SizedBox()),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildTextButton(
                text: 'Modifier le profil',
                onPressed: () {
                  final rootNav = Navigator.of(context, rootNavigator: true);
                  try {
                    rootNav.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()), // TODO: replace
                          (_) => false,
                    );
                  } catch (_) {}
                  Navigator.pushNamed(context, Routes.profileScreen);
                },
              ),
              // more options...
            ],
          ),
        ),

        // ---- Logout button (updated) ----
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
          child: ElevatedButton(
            onPressed: auth.loading
                ? null
                : () async {
              final ctrl = context.read<AuthController>();
              await ctrl.logout();

              // Always navigate using the ROOT navigator
              final rootNav = Navigator.of(context, rootNavigator: true);
              if (!rootNav.mounted) return;

              // If your repo didn't clear the token, the guard will bounce you back to Home.
              // We'll still attempt navigation robustly:
              bool navigated = false;

              // Try named route (ensure Routes.authScreen exists)
              try {
                rootNav.pushNamedAndRemoveUntil(Routes.authScreen, (_) => false);
                navigated = true;
              } catch (_) {}

              // Fallback: push the widget directly (CHANGE AuthScreen to your login/auth widget)
              if (!navigated) {
                try {
                  rootNav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()), // TODO: replace
                        (_) => false,
                  );
                  navigated = true;
                } catch (_) {}
              }

              // Last resort: just clear the stack
              if (!navigated) {
                rootNav.popUntil((r) => r.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: auth.loading
                ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/logout.svg',
                  color: Colors.white,
                  height: 24, width: 24,
                ),
                const SizedBox(width: 16),
                const Text(
                  'Déconnexion',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        )

        ,
      ],
    );
  }

  TextButton _buildTextButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        maximumSize: const Size(double.infinity, 50),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
