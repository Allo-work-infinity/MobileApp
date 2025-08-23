import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/utils/constants.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    Key? key,
    required this.text,
    this.onTapFacebook,
    this.onTapGoogle,
  }) : super(key: key);

  final String text;
  final VoidCallback? onTapGoogle;
  final VoidCallback? onTapFacebook;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: blackColor,
          ),
        ),
        const SizedBox(width: 40),
        InkWell(
          onTap: onTapGoogle,
          child: SvgPicture.asset('assets/icons/google_logo.svg'),
        ),
        const SizedBox(width: 20),
        InkWell(
          onTap: onTapFacebook,
          child: SvgPicture.asset('assets/icons/facebook_logo.svg'),
        ),
      ],
    );
  }
}
