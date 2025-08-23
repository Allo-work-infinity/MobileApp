import 'package:flutter/material.dart';

class TagText extends StatelessWidget {
  const TagText({
    Key? key,
    required this.text,
    this.textColor = Colors.white,
    this.fontSize = 12,
    this.borderRadius = 6,
    this.bgColor,
    this.marginRight = 8,
    this.padding = const EdgeInsets.all(4),
  }) : super(key: key);

  final String text;
  final Color textColor;
  final Color? bgColor;
  final double fontSize;
  final double borderRadius;
  final double marginRight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: marginRight),
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor ?? textColor.withOpacity(.15),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, color: textColor),
        ),
      ),
    );
  }
}
