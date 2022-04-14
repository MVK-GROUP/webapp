import 'package:flutter/material.dart';
import 'order_element_widget.dart';
import '../style.dart';

class OrderTile extends StatelessWidget {
  final String title;
  final String place;
  final String date;
  final VoidCallback onPressed;

  const OrderTile(
      {required this.title,
      required this.place,
      required this.date,
      required this.onPressed,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        constraints: const BoxConstraints(minHeight: 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  OrderElementWidget(
                    iconData: Icons.location_on,
                    text: place,
                  ),
                  const SizedBox(height: 5),
                  OrderElementWidget(
                    iconData: Icons.calendar_month,
                    text: date,
                  ),
                ],
              ),
            ),
            const Icon(Icons.remove_red_eye, color: mainColor)
          ],
        ),
      ),
    );
  }
}
