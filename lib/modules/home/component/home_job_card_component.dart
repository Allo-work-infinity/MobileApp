import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/utils/k_images.dart';

class HomeJobCardComponent extends StatelessWidget {
  const HomeJobCardComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xffFAFAFA),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Software Engineer",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2c2c2c)),
              ),
              SizedBox(height: 4),
              Text(
                "Dhaka, Bangladesh",
                style: TextStyle(fontSize: 12, color: Color(0xff939393)),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.more_horiz_outlined),
        ],
      ),
    );
  }
}
