import 'package:flutter/material.dart';
import 'package:job_finding/utils/constants.dart';
import 'package:job_finding/widget/appbar_button.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  bool isExpanded = false;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 0.0,
        title: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: labelColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios,
                color: blackColor,
                size: 16,
              ),
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: 12,
                right: 4,
              ),
              margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
            ),
            const Text(
              'FAQ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: const AppbarButton(icon: 'assets/icons/search.svg'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: List.generate(5, (index) {
            return _buildFAQItem(index);
          }),
        ),
      ),
    );
  }

  _buildFAQItem(index) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        expandedAlignment: Alignment.topLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        leading: Icon(
          _currentIndex == index && isExpanded
              ? Icons.remove_circle
              : Icons.add_circle_sharp,
          color: _currentIndex == index && isExpanded
              ? secondaryColor
              : blackColor,
        ),
        onExpansionChanged: (value) {
          setState(() {
            isExpanded = value;
            _currentIndex = index;
          });
        },
        trailing: const SizedBox(),
        title: Text(
          'How do I place an order on your website?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _currentIndex == index && isExpanded
                ? secondaryColor
                : blackColor,
          ),
        ),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Text(
              "Ut faucibus vulputate mollis. Vivamus libero ipsum, mollis nec elit. Ut faucibus vulputate mollis Vivamus libero ipum, mollis nec elit.",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: captionTextColor,
              ),
            ),
          ),
          Divider(
            thickness: 1,
            color: blackColor.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
