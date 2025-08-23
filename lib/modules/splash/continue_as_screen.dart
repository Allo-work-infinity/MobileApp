import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/router_name.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';

class ContinueAsScreen extends StatefulWidget {
  const ContinueAsScreen({Key? key}) : super(key: key);

  @override
  State<ContinueAsScreen> createState() => _ContinueAsScreenState();
}

class _ContinueAsScreenState extends State<ContinueAsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(child: SvgPicture.asset(Kimages.logoBlackIcon)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  'Continue as',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: blackColor,
                  ),
                ),
              ),
              ContinueButton(
                onTap: () {
                  Navigator.pushReplacementNamed(context, Routes.authScreen);
                },
                text: 'Candidate',
                caption: 'Let’s recruit your great\ncandidate faster here',
                icon: Kimages.arrowWhite,
                backgroundColor: blackColor,
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.4),
                    offset: const Offset(4, 8),
                    blurRadius: 20,
                  ),
                ],
              ),
              ContinueButton(
                onTap: () {
                  Navigator.pushReplacementNamed(context, Routes.authScreen);
                },
                text: 'Company',
                caption: 'Finding a job here never\nbeen easier than before',
                icon: Kimages.arrowBlack,
                backgroundColor: circleColor.withOpacity(0.4),
                reverse: true,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ],
      ),
    );
  }
}

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    Key? key,
    required this.onTap,
    required this.text,
    required this.caption,
    required this.icon,
    required this.backgroundColor,
    this.reverse = false,
    this.boxShadow,
  }) : super(key: key);

  final VoidCallback onTap;
  final String text;
  final String caption;
  final String icon;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24, left: 20, right: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: boxShadow,
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 32,
                horizontal: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: reverse ? blackColor : primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    caption,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: reverse
                          ? blackColor.withOpacity(0.8)
                          : primaryColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -8,
              child: SvgPicture.asset(
                Kimages.arrowVector,
                color: labelColor.withOpacity(0.5),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SvgPicture.asset(icon),
            ),
          ],
        ),
      ),
    );
  }
}
