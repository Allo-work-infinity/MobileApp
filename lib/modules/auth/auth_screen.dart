import 'package:flutter/material.dart';
import 'package:job_finding/modules/auth/components/login_container.dart';
import 'package:job_finding/modules/auth/components/register_container.dart';
import 'package:job_finding/utils/constants.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth: 12,
          title: const Text(
            'Candidate',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottom: const TabBar(
            unselectedLabelColor: blackColor,
            labelColor: secondaryColor,
            indicatorColor: secondaryColor,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            tabs: [
              Tab(text: 'Se connecter'),
              Tab(text: 'Registre'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LoginContainer(),
            RegisterContainer(),
          ],
        ),
      ),
    );
  }
}
