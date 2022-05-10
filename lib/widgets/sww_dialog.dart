import 'package:flutter/material.dart';

class SomethingWentWrongDialog extends StatelessWidget {
  final String title;
  final String bodyMessage;
  const SomethingWentWrongDialog(
      {this.title = "Щось пішло не так...",
      this.bodyMessage = "Вибачте, в нас технічні неспровності :(",
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(bodyMessage),
      actionsPadding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      actionsOverflowButtonSpacing: 8,
      actionsOverflowDirection: VerticalDirection.up,
      actions: [
        TextButton(
          child: const Text('Ок'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        const SizedBox(width: 5),
      ],
    );
  }
}
