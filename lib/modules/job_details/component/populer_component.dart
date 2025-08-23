import 'package:flutter/material.dart';
import 'package:job_finding/utils/constants.dart';

class PopulerComponent extends StatelessWidget {
  final String description;

  const PopulerComponent({
    Key? key,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        description,
        style: const TextStyle(color: paragraphColor),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
