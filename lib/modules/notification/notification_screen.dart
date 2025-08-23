import 'package:flutter/material.dart';
import 'package:job_finding/modules/notification/components/notification_item.dart';
import 'package:job_finding/utils/constants.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

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
              'Notification',
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
                const SizedBox(height: 20),
                const Text(
                  'Today  -  10 July, 2021',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: captionTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNotification(),
                const SizedBox(height: 30),
                const Text(
                  '8 July, 2021',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: captionTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNotification(),
                const SizedBox(height: 30),
                const Text(
                  '7 July, 2021',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: captionTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNotification(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildNotification() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: labelColor.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NotificationItem(
            icon: 'assets/icons/notification1.svg',
            color: skillsColorTwo,
            title: 'Serial reminder',
            caption:
                'You has apply an job in Queenify\nGroup as UI Designer...',
          ),
          const SizedBox(height: 16),
          Divider(
            thickness: 1,
            color: blackColor.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          const NotificationItem(
            icon: 'assets/icons/video1.svg',
            color: skillsColorThree,
            title: 'Congratulations!',
            caption:
                'Your interview will held in video\ncall. Check schedule...',
          ),
          const SizedBox(height: 16),
          Divider(
            thickness: 1,
            color: blackColor.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          const NotificationItem(
            icon: 'assets/icons/shield_done.svg',
            color: skillsColorOne,
            title: 'Terms & Conditions',
            caption: 'Read our new Terms & Conditions.',
          ),
        ],
      ),
    );
  }
}
