import 'package:flutter/material.dart';
import 'package:job_finding/utils/constants.dart';

class CustomToggleButton extends StatefulWidget {
  const CustomToggleButton({
    Key? key,
    required this.label,
    required this.onTap,
    required this.isFirst,
  }) : super(key: key);
  final int isFirst;
  final List<String> label;

  final ValueChanged<int> onTap;

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.isFirst;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: blackColor),
      child: Row(
        children: widget.label.map((e) {
          int index = widget.label.indexOf(e);
          return _buildButton(e, index);
        }).toList(),
      ),
    );
  }

  Widget _buildButton(String text, int index) {
    bool isSelected = index == selectedIndex;
    return Flexible(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color:
              isSelected ? Colors.white.withOpacity(0.25) : Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onTap(selectedIndex);
            },
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
