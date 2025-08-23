// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_finding/modules/SubscriptionPlan/controller/payment_controller.dart';
import 'package:provider/provider.dart';

import 'utils/k_strings.dart';
import 'utils/my_theme.dart';
import 'auth_gate.dart';

// Auth
import 'modules/auth/controller/auth_controller.dart';
import 'modules/auth/repository/auth_repository.dart';

// Subscription Plans
import 'modules/SubscriptionPlan/controller/plan_controller.dart';
import 'modules/SubscriptionPlan/repository/subscription_plan_repository.dart';

// Payment (Controller) + Repos
import 'modules/SubscriptionPlan/repository/payment_repository.dart';
import 'modules/SubscriptionPlan/repository/payment_transaction_repository.dart';

// Categories
import 'modules/home/controller/category_controller.dart';
import 'modules/home/repository/category_repository.dart';

// Job Offers
import 'modules/home/controller/job_offer_controller.dart';
import 'modules/home/repository/job_offer_repository.dart';

// Job Applications (AppliedScreen)
import 'modules/applied_screen/controller/job_application_controller.dart';
import 'modules/applied_screen/repository/job_application_repository.dart';

// Company (used by CompanyComponent)
import 'modules/job_details/controllers/company_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  const String apiBaseUrl = 'http://192.168.1.193:8000';

  runApp(
    MultiProvider(
      providers: [
        // ---------- Auth ----------
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(AuthRepository(baseUrl: apiBaseUrl))..init(),
        ),

        // ---------- Payment ----------
        // Uses AuthController's token; stays in sync when user logs in/out.
        ChangeNotifierProxyProvider<AuthController, PaymentController>(
          create: (ctx) => PaymentController(
            paymentRepo: PaymentRepositoryHttp(baseUrl: apiBaseUrl),
            // txRepo is optional; include it if you plan to create/update transactions
            txRepo: PaymentTransactionRepositoryHttp(baseUrl: apiBaseUrl),
            bearerToken: ctx.read<AuthController>().token, // initial token (may be null)
          ),
          update: (ctx, auth, ctrl) {
            ctrl?.setBearerToken(auth.token); // keep token synced
            return ctrl!;
          },
        ),

        // ---------- Subscription Plans ----------
        ChangeNotifierProvider<PlanController>(
          create: (ctx) => PlanController(
            SubscriptionPlanRepository(
              baseUrl: apiBaseUrl,
              tokenProvider: () => ctx.read<AuthController>().token,
            ),
          ),
        ),

        // ---------- Categories ----------
        ChangeNotifierProvider<CategoryController>(
          create: (_) => CategoryController(
            CategoryRepository(baseUrl: apiBaseUrl),
          )..init(),
        ),

        // ---------- Job Offers ----------
        ChangeNotifierProvider<JobOfferController>(
          create: (_) => JobOfferController(
            JobOfferRepository(baseUrl: apiBaseUrl),
          ),
        ),

        // ---------- Job Applications ----------
        ChangeNotifierProvider<JobApplicationController>(
          create: (_) => JobApplicationController(
            JobApplicationRepository(baseUrl: apiBaseUrl),
          ),
        ),

        // ---------- Company (component use) ----------
        ChangeNotifierProvider<CompanyController>(
          create: (_) => CompanyController.withBaseUrl(apiBaseUrl),
          // If your endpoint later requires auth:
          // create: (ctx) => CompanyController.withBaseUrl(
          //   apiBaseUrl,
          //   defaultHeaders: {'Authorization': 'Bearer ${ctx.read<AuthController>().token ?? ''}'},
          // ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Kstrings.appName,
      theme: MyTheme.theme,
      home: const AuthGate(),
    );
  }
}
