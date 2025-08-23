// lib/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:job_finding/modules/SubscriptionPlan/payment_pending_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'modules/auth/controller/auth_controller.dart';
import 'modules/home/home_page.dart';
import 'modules/auth/auth_screen.dart';
import 'modules/splash/splash_screen.dart';
import 'modules/SubscriptionPlan/plans_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _firstRunFuture;

  @override
  void initState() {
    super.initState();
    _firstRunFuture = _isFirstRun();
  }

  static Future<bool> _isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'has_run_before';
    final isFirst = !(prefs.getBool(key) ?? false);
    if (isFirst) {
      await prefs.setBool(key, true);
    }
    return isFirst;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    // Decide first-run vs normal flow *first*
    return FutureBuilder<bool>(
      future: _firstRunFuture,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isFirstRun = snap.data == true;
        if (isFirstRun) {
          // Show onboarding immediately on first run
          return const SplashScreen();
        }

        // Not first run -> now consider auth init state
        if (auth.initializing) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Not authenticated -> Auth
        if (!auth.isAuthenticated) {
          return const AuthScreen();
        }

        // Authenticated -> check subscription
        return auth.hasActiveSubscription ? const PaymentPendingScreen() : const PlansScreen();
      },
    );
  }
}
