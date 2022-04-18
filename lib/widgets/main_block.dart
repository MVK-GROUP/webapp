import 'package:flutter/material.dart';
import '../style.dart' show secondaryBackgroundColor;

class MainBlock extends StatelessWidget {
  final Widget child;
  final double hContentPadding;
  const MainBlock({required this.child, this.hContentPadding = 30, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
              color: secondaryBackgroundColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(20),
                  height: 8,
                  width: 80,
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: 46, left: hContentPadding, right: hContentPadding),
                  child: child)
            ],
          )),
    );
  }
}
