import 'package:flutter/material.dart';
import 'package:job_finding/utils/constants.dart';

class HaveAnAccountOrNotView extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLogin;

  const HaveAnAccountOrNotView(
      {Key? key, this.onPressed, required this.isLogin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.subtitle1!.copyWith(
      fontWeight: FontWeight.w800,
      color: blackColor,
    );
    final linkStyle = Theme.of(context).textTheme.subtitle1!.copyWith(
      fontWeight: FontWeight.bold,
      color: secondaryColor,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,      // gap between text and button
        runSpacing: 4,   // vertical gap when it wraps
        children: [
          Text(
            isLogin
                ? "Vous n'avez pas de compte ?"
                : "Vous avez déjà un compte ?",
            style: labelStyle,
          ),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              !isLogin ? 'Se connecter' : 'Registre',
              style: linkStyle,
            ),
          ),
        ],
      ),
    );
  }
}