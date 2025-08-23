import 'package:flutter/material.dart';

class JobCustomAppBar extends StatelessWidget {
  const JobCustomAppBar(
      {Key? key, this.text = "Search", this.bgColor = Colors.white})
      : super(key: key);
  final String text;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            text,
            style: const TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Colors.white,
                fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.bookmark_border_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
