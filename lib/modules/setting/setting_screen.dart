import 'package:flutter/material.dart';
import 'package:job_finding/router_name.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/widget/custom_switch.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool pushNotification = true;
  bool reminder = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: blackColor,
                  size: 16,
                ),
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  left: 12,
                  right: 4,
                ),
                margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
              ),
            ),
            const Text(
              'Setting',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'General',
                  style: TextStyle(
                    fontSize: 14,
                    color: captionTextColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                CustomSwitch(
                  onTap: () {
                    setState(() {
                      pushNotification = !pushNotification;
                    });
                  },
                  text: 'Push Notification',
                  isActive: pushNotification,
                ),
                ListTile(
                  onTap: () {},
                  contentPadding: EdgeInsets.zero,
                  leading: Image.asset('assets/images/flag_uk.png'),
                  title: const Text(
                    'English (UK)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: blackColor,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: captionTextColor,
                  ),
                ),
                CustomSwitch(
                  onTap: () {
                    setState(() {
                      reminder = !reminder;
                    });
                  },
                  text: 'Reminder',
                  isActive: reminder,
                ),
                CustomSwitch(
                  onTap: () {
                    setState(() {
                      darkMode = !darkMode;
                    });
                  },
                  text: 'Dark Mode',
                  isActive: darkMode,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Support',
                  style: TextStyle(
                    fontSize: 14,
                    color: captionTextColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                buildListTile('FAQ'),
                buildListTile('Help'),
                buildListTile('Terms & Condition'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile buildListTile(String text) {
    return ListTile(
      onTap: () {
        Navigator.pushNamed(context, Routes.faqScreen);
      },
      contentPadding: EdgeInsets.zero,
      title: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: blackColor,
        ),
      ),
    );
  }
}
