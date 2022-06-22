import 'package:flutter/material.dart';

enum IconLocation {
  left,
  right,
}

class MainButton extends StatelessWidget {
  final String text;
  final bool isWaitingButton;
  final IconData? icon;
  final IconLocation iconLocation;
  final VoidCallback? onButtonPress;
  final double mHorizontalInset;

  const MainButton({
    Key? key,
    this.text = "",
    this.isWaitingButton = false,
    this.icon,
    this.iconLocation = IconLocation.left,
    this.onButtonPress,
    this.mHorizontalInset = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: mHorizontalInset),
      child: ElevatedButton(
        onPressed: onButtonPress,
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(2),
          overlayColor: MaterialStateProperty.all(Colors.black12),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          //backgroundColor: MaterialStateProperty.all(mainColor),
          fixedSize: MaterialStateProperty.all(const Size(412, 60)),
        ),
        child: Row(
          children: [
            if (icon != null && iconLocation == IconLocation.left) buildIcon(),
            const Spacer(),
            isWaitingButton
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color.fromARGB(221, 255, 255, 255),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0),
                  ),
            const Spacer(),
            if (icon != null && iconLocation == IconLocation.right) buildIcon(),
          ],
        ),
      ),
    );
  }

  Icon buildIcon() {
    return Icon(
      icon,
      size: 30,
    );
  }
}
