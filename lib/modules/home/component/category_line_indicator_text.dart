import 'package:flutter/material.dart';
import 'package:job_finding/utils/constants.dart';

class CategoryLineIndecatorText extends StatelessWidget {
  const CategoryLineIndecatorText({
    Key? key,
    required this.text,
    required this.isCurrentItem,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  final ValueChanged<int> onTap;

  final String text;
  final int index;
  final bool isCurrentItem;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap(index);
      },
      child: isCurrentItem ? _selectedCatText(text) : _unselectedCatText(text),
    );
  }

  Widget _selectedCatText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 1,
            width: 20,
            color: const Color(0xffFC5E53),
          ),
        ],
      ),
    );
  }

  Widget _unselectedCatText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            text,
            style: const TextStyle(
                color: paragraphColor, fontSize: 14, height: 1.55),
          ),
        ],
      ),
    );
  }
}
