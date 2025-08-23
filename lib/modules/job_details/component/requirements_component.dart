import 'package:flutter/material.dart';
import 'package:job_finding/utils/constants.dart';

class RequirementsComponent extends StatelessWidget {
  const RequirementsComponent({Key? key, required this.requirementList})
      : super(key: key);

  final List<String> requirementList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: requirementList
            .map((text) => _singleRequirementItem(text))
            .toList(),
      ),
    );
  }

  Widget _singleRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: CircleAvatar(radius: 2, backgroundColor: blackColor),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: paragraphColor, height: 2),
            ),
          ),
        ],
      ),
    );
  }
}
