import 'package:flutter/material.dart';
import 'package:job_finding/utils/constants.dart';

class ChatCustomAppBar extends StatelessWidget {
  const ChatCustomAppBar({Key? key, this.name = "Sowkot"}) : super(key: key);
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                color: boarderColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.arrow_back_ios_new),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                        color: boarderColor,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        height: 1.5, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
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
              child: const Icon(Icons.wifi_calling),
            ),
          ),
        ],
      ),
    );
  }
}
