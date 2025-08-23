import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:job_finding/utils/constants.dart';

class FeedBackCard extends StatelessWidget {
  const FeedBackCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                  color: circleColor, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(width: 8),
            const Text(
              "Sowkot",
              style: TextStyle(fontWeight: FontWeight.w500),
            )
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              ignoreGestures: true,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 12,
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: secondaryColor),
              onRatingUpdate: (rating) {},
            ),
            const SizedBox(width: 8),
            const Text(
              "14/10/2020",
              style: TextStyle(color: paragraphColor, fontSize: 12),
            )
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Ut faucibus vulputate mollis. Vivamus libero ipsum, mollis nec elit. Ut faucibus vulputate mollis Vivamus libero ipum, mollis nec elit.",
          textAlign: TextAlign.justify,
          style: TextStyle(color: suffixColor),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text("Was this review helpful?",
                  style: TextStyle(fontSize: 12)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: .5, color: paragraphColor)),
              child: const Text(
                "Yes",
                style:
                    TextStyle(fontSize: 10, color: paragraphColor, height: 1.2),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: .5, color: paragraphColor)),
              child: const Text(
                "Yes",
                style:
                    TextStyle(fontSize: 10, color: paragraphColor, height: 1.2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(color: boarderColor, height: 1),
        const SizedBox(height: 16),
      ],
    );
  }
}
