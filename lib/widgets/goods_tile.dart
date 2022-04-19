import 'package:flutter/material.dart';
import 'package:mvk_app/style.dart';

class GoodsItemTileWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final Widget? subTitle;
  final double height;
  final double width;
  final TextAlign textAlign;
  final VoidCallback? onTap;

  const GoodsItemTileWidget(
      {required this.imagePath,
      required this.title,
      this.subTitle,
      this.onTap,
      this.height = 180,
      this.width = 150,
      this.textAlign = TextAlign.center,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [AppShadows.getShadow200()],
        ),
        child: Column(
          children: [
            SizedBox(
                height: height * 0.5,
                child: Image.asset(imagePath, fit: BoxFit.fitWidth)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.maxFinite,
              child: Text(
                title,
                textAlign: textAlign,
              ),
            ),
            if (subTitle != null)
              SizedBox(
                width: double.maxFinite,
                child: subTitle,
              ),
          ],
        ),
      ),
    );
  }
}
