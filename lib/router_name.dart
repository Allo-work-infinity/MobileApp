import 'package:flutter/material.dart';
import 'package:job_finding/modules/account/account_screen.dart';
import 'package:job_finding/modules/auth/auth_screen.dart';
import 'package:job_finding/modules/faq/faq_screen.dart';
import 'package:job_finding/modules/home/filtered_offers_screen.dart';
import 'package:job_finding/modules/home/home_page.dart';
import 'package:job_finding/modules/notification/notification_screen.dart';
import 'package:job_finding/modules/notification/notification_setting_screen.dart';
import 'package:job_finding/modules/profile/profile_screen.dart';
import 'package:job_finding/modules/setting/setting_screen.dart';
import 'package:job_finding/modules/splash/continue_as_screen.dart';
import 'package:job_finding/modules/splash/splash_screen.dart';
import 'modules/applied_screen/applied_screen.dart';
import 'modules/job_details/job_details_screen.dart';
import 'modules/message/chat_list_screen.dart';
import 'modules/message/chat_screen.dart';
import 'modules/search/search_init_screen.dart';
import 'modules/search/search_result_screen.dart';

class Routes {
  static const String home = '/';

  static String search = "/searchInit";
  static String searchResult = "/searchResult";
  static String appliedScreen = "/appliedScreen";
  static String chatListScreen = "/chatListScreen";
  static String chatScreen = "/chatScreen";
  static String jobDetailsScreen = "/jobDetailsScreen";
  static String splashScreen = "/splashScreen";
  static String continueAsScreen = "/continueAsScreen";
  static String authScreen = "/authScreen";
  static String accountScreen = "/accountScreen";
  static String profileScreen = "/ProfileScreen";
  static String notificationSettingScreen = "/notificationSettingScreen";
  static String notificationScreen = "/notificationScreen";
  static String settingScreen = "/settingScreen";
  static String faqScreen = "/faqScreen";

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    splashScreen: (context) => const SplashScreen(),
    continueAsScreen: (context) => const ContinueAsScreen(),
    authScreen: (context) => const AuthScreen(),
    accountScreen: (context) => const AccountScreen(),
    profileScreen: (context) => const ProfileScreen(),
    notificationSettingScreen: (context) => const NotificationSettingScreen(),
    notificationScreen: (context) => const NotificationScreen(),
    faqScreen: (context) => const FAQScreen(),
    settingScreen: (context) => const SettingScreen(),
    search: (context) => const SearchInitScreen(),
    searchResult: (context) => const SearchResultScreen(),
    appliedScreen: (context) => const AppliedScreen(),
    chatListScreen: (context) => const ChatListScreen(),
    chatScreen: (context) => const ChatScreen(),
    // jobDetailsScreen: (context) => const JobDetailsScreen(),
    chatScreen: (context) => const ChatScreen(),
  };
}
