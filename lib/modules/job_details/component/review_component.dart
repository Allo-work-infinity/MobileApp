import 'package:flutter/material.dart';
import 'feedback_card.dart';
import 'rating_preview_component.dart';

class ReviewComponent extends StatelessWidget {
  const ReviewComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: const [
          SizedBox(height: 8),
          RatingPreviewComponent(),
          SizedBox(height: 30),
          FeedBackCard(),
          FeedBackCard(),
          FeedBackCard(),
          FeedBackCard(),
          FeedBackCard(),
          FeedBackCard(),
          FeedBackCard(),
          FeedBackCard(),
          FeedBackCard(),
        ],
      ),
    );
  }
}
