import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/router_name.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';
import 'package:job_finding/widget/teg_text.dart';

class JobCardComponent extends StatelessWidget {
  const JobCardComponent({
    Key? key,
    required this.address,
    required this.title,
    required this.tags,
  }) : super(key: key);

  final List<String> tags;
  final String title;
  final String address;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:()=>{},
          // () => Navigator.pushNamed(context, Routes.jobDetailsScreen),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: boarderColor, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Center(child: SvgPicture.asset(Kimages.uiLeadIcon)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2c2c2c)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xff939393)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    alignment: Alignment.topRight,
                    child: const Icon(Icons.bookmark_outline_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ...tags
                    .take(3)
                    .map(
                      (e) => TagText(
                        text: e,
                        textColor: blackColor,
                        bgColor: Colors.white,
                      ),
                    )
                    .toList(),
                const Spacer(),
                const Text.rich(
                  TextSpan(
                    text: "\$12",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor),
                    children: [
                      TextSpan(
                        text: "/m",
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff939393),
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
