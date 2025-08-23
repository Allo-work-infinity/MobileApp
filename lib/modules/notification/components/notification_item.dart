import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/utils/constants.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    Key? key,
    required this.icon,
    required this.color,
    required this.title,
    required this.caption,
  }) : super(key: key);

  final String icon;
  final Color color;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
          ),
          child: Center(child: SvgPicture.asset(icon)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                caption,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: captionTextColor,
                ),
              ),
            ],
          ),
        ),
        const Text(
          '5h ago',
          maxLines: 1,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: captionTextColor,
          ),
        ),
      ],
    );
  }
}
