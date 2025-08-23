import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/utils/constants.dart';

class AppbarButton extends StatelessWidget {
  const AppbarButton({
    Key? key,
    required this.icon,
  }) : super(key: key);

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: labelColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: SvgPicture.asset(
          icon,
          color: blackColor,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(right: 20, top: 6, bottom: 6),
    );
  }
}
