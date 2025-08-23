import 'package:flutter/material.dart';
import 'package:job_finding/utils/constants.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({
    Key? key,
    required this.onTap,
    required this.text,
    this.isActive = false,
  }) : super(key: key);

  final VoidCallback onTap;
  final String text;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: blackColor,
                ),
              ),
            ),
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: labelColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: isActive
                  ? Center(
                      child: Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: blackColor.withOpacity(0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 6,
                            ),
                          ],
                          color: blackColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
