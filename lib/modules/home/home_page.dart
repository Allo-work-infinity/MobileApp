import 'package:flutter/material.dart';
import 'package:job_finding/custom_navbar/custom_navbar.dart';
import 'package:job_finding/modules/account/account_screen.dart';
import 'package:job_finding/modules/applied_screen/applied_screen.dart';
import 'package:job_finding/modules/home/home_view.dart';
import 'package:job_finding/modules/message/chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> screens = const [
    HomeView(),
    // AppliedScreen(),
    // ChatListScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        height: 72,
        currentIndex: _currentIndex,
        onItemSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
