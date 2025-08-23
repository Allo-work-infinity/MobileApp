import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ApplyProcessView extends StatefulWidget {
  const ApplyProcessView({Key? key, this.onChanged}) : super(key: key);

  final ValueChanged<int>? onChanged;

  @override
  State<ApplyProcessView> createState() => _ApplyProcessViewState();
}

class _ApplyProcessViewState extends State<ApplyProcessView> {
  int counter = 0;

  int _currentIndex = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      setState(() {
        if (_currentIndex == 0) {
          _currentIndex = 1;
        } else if (_currentIndex == 1) {
          _currentIndex = 2;
        } else {
          _currentIndex = 0;
        }

        if (widget.onChanged != null) {
          widget.onChanged!.call(counter++);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _column();
  }

  _column() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Spacer(),
        Center(child: SvgPicture.asset('assets/images/logo_black.svg')),
        const SizedBox(height: 24),
        Center(
          child: AnimatedSmoothIndicator(
            count: 3,
            effect: const ExpandingDotsEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: Colors.white,
              dotColor: Colors.grey,
            ),
            activeIndex: _currentIndex,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
