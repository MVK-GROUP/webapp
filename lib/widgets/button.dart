import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style.dart';

class ElevatedWaitingButton extends StatelessWidget {
  final String text;
  final double maxWidth;
  final TextStyle? textStyle;
  final double borderRadius;

  const ElevatedWaitingButton({
    required this.text,
    this.textStyle,
    this.maxWidth = 310,
    this.borderRadius = 10.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      constraints: const BoxConstraints(maxWidth: 310),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius))),
          onPressed: null,
          child: Row(
            children: [
              const SizedBox(
                  width: 24, height: 24, child: CircularProgressIndicator()),
              const SizedBox(width: 5),
              Expanded(
                  child: Text(text,
                      textAlign: TextAlign.center,
                      style: textStyle ??
                          GoogleFonts.montserrat(
                              fontSize: 16, fontWeight: FontWeight.w600))),
            ],
          )),
    );
  }
}

class ElevatedIconButton extends StatelessWidget {
  final Icon icon;
  final String text;
  final VoidCallback? onPressed;
  final double maxWidth;
  final TextStyle? textStyle;
  final double borderRadius;

  const ElevatedIconButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.textStyle,
    this.maxWidth = 310,
    this.borderRadius = 10.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      constraints: const BoxConstraints(maxWidth: 310),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius))),
        onPressed: onPressed,
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Expanded(
                child: Text(text,
                    textAlign: TextAlign.center,
                    style: textStyle ??
                        GoogleFonts.montserrat(
                            fontSize: 16, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}

class ElevatedDefaultButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color buttonColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const ElevatedDefaultButton(
      {required this.child,
      required this.onPressed,
      this.buttonColor = AppColors.mainColor,
      this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      this.borderRadius = 10.0,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      constraints: const BoxConstraints(maxWidth: 310),
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
        style: ElevatedButton.styleFrom(
            primary: buttonColor,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            )),
      ),
    );
  }
}
