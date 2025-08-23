import 'package:flutter/material.dart';
import 'package:job_finding/utils/constants.dart';

class SkillItemView extends StatelessWidget {
  const SkillItemView({
    Key? key,
    required this.icon,
    required this.text,
    required this.percent,
    required this.color,
  }) : super(key: key);

  final String icon;
  final String text;
  final String percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Image.asset(icon),
                ),
                const SizedBox(width: 8),
                Text(
                  percent,
                  style: const TextStyle(
                    color: captionTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Text(
              text,
              style: const TextStyle(
                color: blackColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
