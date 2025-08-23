import 'package:flutter/material.dart';
import 'package:job_finding/utils/constants.dart';

class MessageCustomAppBar extends StatelessWidget {
  const MessageCustomAppBar({Key? key, this.text = "Search"}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: boarderColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.arrow_back_ios_new),
          ),
        ),
        const SizedBox(width: 24),
        Text(
          text,
          style: const TextStyle(
              fontSize: 18, height: 1.5, fontWeight: FontWeight.w500),
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
              color: boarderColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.search),
          ),
        ),
      ],
    );
  }
}
