import 'package:flutter/material.dart';
import '../style.dart';

class DefaultDialog extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Widget body;
  final double maxHeight;
  final bool useProgressBar;

  const DefaultDialog({
    required this.title,
    required this.body,
    this.titleColor = AppColors.secondaryColor,
    this.maxHeight = 500,
    this.useProgressBar = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400, maxHeight: maxHeight),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 5),
                    child: IconButton(
                        iconSize: 32,
                        color: AppColors.mainColor,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close))),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: body,
              ),
              if (useProgressBar)
                Align(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: const ClipRRect(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                          child: LinearProgressIndicator(
                            minHeight: 5,
                          ))),
                ),
            ],
          ),
        ));
  }
}
