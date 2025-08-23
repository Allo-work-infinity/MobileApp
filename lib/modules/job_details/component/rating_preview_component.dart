import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:job_finding/utils/constants.dart';

class RatingPreviewComponent extends StatelessWidget {
  const RatingPreviewComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "4.8",
                style: TextStyle(
                    fontSize: 40, height: 1.2, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 12,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: secondaryColor),
                onRatingUpdate: (rating) {},
              ),
              const SizedBox(height: 2),
              const Text(
                "44,887",
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _singleProgressLine(5, .9),
              _singleProgressLine(4, .7),
              _singleProgressLine(3, .5),
              _singleProgressLine(2, .3),
              _singleProgressLine(1, .2),
            ],
          ),
        )
      ],
    );
  }

  Padding _singleProgressLine(int pos, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            "$pos",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              backgroundColor: boarderColor,
              color: secondaryColor,
              minHeight: 6,
              value: progress,
            ),
          ),
        ],
      ),
    );
  }
}
