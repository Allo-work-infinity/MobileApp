import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class Utils {
  static final _selectedDate = DateTime.now();

  static final _initialTime = TimeOfDay.now();

  static String formatPrice(double price) => '${price.toStringAsFixed(2)}\TND ';

  static String formatDate(DateTime date) => DateFormat.yMd().format(date);

  static String numberCompact(num number) =>
      NumberFormat.compact().format(number);

  static String timeAgo(String? time) {
    try {
      if (time == null) return '';
      return timeago.format(DateTime.parse(time));
    } catch (e) {
      return '';
    }
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(message, textAlign: TextAlign.center),
    ));
  }

  static Future<DateTime?> selectDate(BuildContext context) => showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1990, 1),
        lastDate: DateTime(2050),
      );

  static Future<TimeOfDay?> selectTime(BuildContext context) =>
      showTimePicker(context: context, initialTime: _initialTime);

  static Future showCongratsAlertDialog(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            child: Container(
              height: 250,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.check,
                      color: Theme.of(context).colorScheme.secondary),
                  Text('Congrats', style: textTheme.headline2),
                  const SizedBox(height: 8),
                  const Text('You did successfully transfer \$85.00 Amount',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        });
  }

  static showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Log out?"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            CupertinoDialogAction(
                isDefaultAction: false,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            CupertinoDialogAction(
                textStyle: const TextStyle(color: Colors.red),
                isDefaultAction: true,
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: const Text("Log out")),
          ],
        );
      },
    );
  }

  static void showCustomDialog(BuildContext context, Widget child,
      {VoidCallback? onTap}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation first, Animation second) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black26,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 32,
                  left: 18,
                  child: GestureDetector(
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    onTap: onTap,
                  ),
                ),
                child,
              ],
            ),
          ),
        );
      },
    );
  }
}
