import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/router_name.dart';

class OptionView extends StatelessWidget {
  const OptionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        Expanded(
          child: Column(
            children: [
              _buildTextButton(
                text: 'Edit Profile',
                onPressed: () {
                  Navigator.pushNamed(context, Routes.profileScreen);
                },
              ),
              _buildTextButton(
                text: 'Notifications',
                onPressed: () {
                  Navigator.pushNamed(context, Routes.notificationSettingScreen);
                },
              ),
              _buildTextButton(
                text: 'Applications',
                onPressed: () {},
              ),
              _buildTextButton(
                text: 'Settings',
                onPressed: () {
                  Navigator.pushNamed(context, Routes.settingScreen);
                },
              ),
            ],
          ),
          flex: 3,
        ),
        Container(
          margin: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 24,
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(primary: Colors.black),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/logout.svg',
                  color: Colors.white,
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 16),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
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
