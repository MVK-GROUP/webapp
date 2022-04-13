import 'package:flutter/material.dart';

class PhotoTile extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  final double height;
  final Function onTap;

  const PhotoTile(
      {required this.id,
      required this.imageUrl,
      required this.title,
      required this.onTap,
      this.height = 100,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 20),
        height: height,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.fitWidth,
                width: double.infinity,
              ),
            ),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
