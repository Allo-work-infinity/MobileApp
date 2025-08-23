import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/utils/k_images.dart';

class JobDetailsHeader extends StatelessWidget {
  const JobDetailsHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: SvgPicture.asset(Kimages.uiLeadIcon)),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "UI Design Lead",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "UI Design Lead",
              style: TextStyle(
                  color: Color(0xffFAFAFA),
                  fontSize: 12,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.center,
                // clipBehavior: Clip.none,
                children: [
                  const SizedBox(width: 64, height: 32),
                  const Positioned(
                    right: 32,
                    child: CircleAvatar(
                      backgroundColor: Color(0xffC4C4C4),
                      radius: 16,
                    ),
                  ),
                  const Positioned(
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Color(0xffC4C4C4),
                      radius: 16,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(.4),
                      ),
                      child: const Center(
                        child: Text(
                          "1k",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                "UI Design Lead",
                style: TextStyle(
                    color: Color(0xffFAFAFA),
                    fontSize: 12,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
        )
      ],
    );
  }
}
