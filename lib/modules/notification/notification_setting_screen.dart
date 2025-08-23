import 'package:flutter/material.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/widget/custom_switch.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool jobPost = true;
  bool appliedStatus = true;
  bool hired = true;
  bool rejected = false;
  bool message = false;
  bool call = false;

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
              'Notification Setting',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            )
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
                const SizedBox(height: 10),
                CustomSwitch(
                  onTap: () {
                    setState(() {
                      jobPost = !jobPost;
                    });
                  },
                  text: 'New Job Post',
                  isActive: jobPost,
                ),
                CustomSwitch(
                  onTap: () {
                    setState(() {
                      appliedStatus = !appliedStatus;
                    });
                  },
                  text: 'Applied Status',
                  isActive: appliedStatus,
                ),
                CustomSwitch(
                  onTap: () {
                    setState(() {
                      hired = !hired;
                    });
                  },
                  text: 'Got Hired',
                  isActive: hired,
                ),
                CustomSwitch(
                  onTap: () {
                    setState(() {
                      rejected = !rejected;
                    });
                  },
                  text: 'Rejected',
                  isActive: rejected,
                ),
                CustomSwitch(
                  onTap: () {
                    setState(() {
                      message = !message;
                    });
                  },
                  text: 'Message',
                  isActive: message,
                ),
                CustomSwitch(
                  onTap: () {
                    setState(() {
                      call = !call;
                    });
                  },
                  text: 'Call',
                  isActive: call,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
