import 'package:flutter/material.dart';
import '../style.dart';

class OrderElementWidget extends StatelessWidget {
  final IconData iconData;
  final String text;

  const OrderElementWidget(
      {required this.iconData, required this.text, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          iconData,
          size: 20,
          color: mainColor,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Text(
              text,
              style: bodySmallText,
            ),
          ),
        ),
      ],
    );
  }
}
