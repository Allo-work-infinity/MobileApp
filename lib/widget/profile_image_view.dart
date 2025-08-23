import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/utils/constants.dart';

class ProfileImageView extends StatelessWidget {
  const ProfileImageView({Key? key}) : super(key: key);

  static const _size = 104.0;
  static const _radius = 34.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: _size,
          width: _size,
          decoration: BoxDecoration(
            color: circleColor, // shows as a subtle frame while image loads
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: Image.asset(
              'assets/images/user.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Colors.white,
                child: Center(child: Icon(Icons.person, size: 40, color: Colors.grey)),
              ),
            ),
          ),
        ),
        // Positioned(
        //   right: -4,
        //   bottom: -4,
        //   child: Container(
        //     decoration: const BoxDecoration(
        //       color: Colors.white,
        //       shape: BoxShape.circle,
        //     ),
        //     padding: const EdgeInsets.all(8),
        //     child: Center(
        //       child: SvgPicture.asset('assets/icons/camera.svg'),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
