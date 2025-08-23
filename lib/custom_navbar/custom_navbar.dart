import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/utils/k_images.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    this.height = 60,
    this.onItemSelected,
  }) : super(key: key);

  final int currentIndex;
  final double height;
  final ValueChanged<int>? onItemSelected;

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: widget.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: InkWell(
                onTap: () {
                  if (widget.onItemSelected != null) widget.onItemSelected!(0);
                  currentIndex = 0;
                  setState(() {});
                },
                child: CustomNavItem(
                  text: "Accueil",
                  isSelected: currentIndex == 0,
                  icon: SvgPicture.asset(
                    Kimages.homeIcon,
                    height: 16,
                    width: 16,
                    color: currentIndex == 0 ? blackColor : null,
                  ),
                  unselectedColor: const Color(0xff2C2C2C),
                  selectedColor: blackColor,
                ),
              ),
            ),
            // Flexible(
            //   child: InkWell(
            //     onTap: () {
            //       if (widget.onItemSelected != null) widget.onItemSelected!(1);
            //       currentIndex = 1;
            //       setState(() {});
            //     },
            //     child: CustomNavItem(
            //       text: "Mes candidatures",
            //       isSelected: currentIndex == 1,
            //       icon: SvgPicture.asset(
            //         Kimages.applicationIcon,
            //         height: 16,
            //         width: 16,
            //         color: currentIndex == 1 ? blackColor : null,
            //       ),
            //       unselectedColor: const Color(0xff2C2C2C),
            //       selectedColor: blackColor,
            //     ),
            //   ),
            // ),
            Flexible(
              child: InkWell(
                onTap: () {
                  widget.onItemSelected?.call(1);      // was 2
                  setState(() => currentIndex = 1);    // was 2
                },
                child: CustomNavItem(
                  text: "Profil",
                  isSelected: currentIndex == 1,       // was == 2
                  icon: SvgPicture.asset(
                    Kimages.profile,               // use your profile svg constant
                    height: 16,
                    width: 16,
                    color: currentIndex == 1 ? blackColor : null, // was == 3
                  ),
                  unselectedColor: const Color(0xff2C2C2C),
                  selectedColor: blackColor,
                ),
              ),
            ),

            // Flexible(
            //   child: InkWell(
            //     onTap: () {
            //       if (widget.onItemSelected != null) widget.onItemSelected!(3);
            //       currentIndex = 3;
            //       setState(() {});
            //     },
            //     child: Container(
            //       alignment: Alignment.center,
            //       child: Stack(
            //         alignment: Alignment.center,
            //         children: [
            //           Tooltip(
            //             message: "profile",
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Container(
            //                   height: 32,
            //                   width: 32,
            //                   decoration: BoxDecoration(
            //                     shape: BoxShape.circle,
            //                     border:
            //                         Border.all(width: 0.25, color: redColor),
            //                   ),
            //                   child: Container(
            //                     margin: const EdgeInsets.all(3),
            //                     decoration: const BoxDecoration(
            //                         shape: BoxShape.circle, color: circleColor),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //           if (currentIndex == 3)
            //             Positioned(
            //               right: 0,
            //               left: 0,
            //               bottom: 0,
            //               child: SvgPicture.asset(Kimages.navIndicateIcon),
            //             ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class CustomNavItem extends StatelessWidget {
  const CustomNavItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.isSelected,
    Color? selectedColor,
    Color? unselectedColor,
  })  : _selectedColor = selectedColor,
        _unselectedColor = unselectedColor,
        super(key: key);

  final String text;
  final Widget icon;
  final bool isSelected;
  final Color? _selectedColor;
  final Color? _unselectedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Tooltip(
        message: text,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                icon,
                const SizedBox(height: 5),
                Text(text,
                    style: TextStyle(
                        color: isSelected ? _selectedColor : _unselectedColor,
                        fontSize: 12))
              ],
            ),
            if (isSelected)
              Positioned(
                right: 0,
                left: 0,
                bottom: 0,
                child: SvgPicture.asset(Kimages.navIndicateIcon),
              ),
          ],
        ),
      ),
    );
  }
}
