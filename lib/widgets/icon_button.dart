import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ElevatedIconButton extends StatelessWidget {
  final Icon icon;
  final String text;
  final VoidCallback onPressed;
  final double maxWidth;

  const ElevatedIconButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.maxWidth = 310,
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
                  borderRadius: BorderRadius.circular(8))),
          onPressed: onPressed,
          child: Row(
            children: [
              icon,
              Expanded(
                  child: Text(text,
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.w600))),
            ],
          )),
    );
  }
}