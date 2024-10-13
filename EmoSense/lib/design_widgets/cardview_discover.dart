import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:emosense/design_widgets//font_style.dart';

class MeditationToolCard extends StatelessWidget {
  final String backgroundImage;
  final String title;
  final VoidCallback? onTap;

  MeditationToolCard({
    required this.backgroundImage,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 2.0, // Adds shadow under the card
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.cover,
                height: screenHeight * 0.24 ,
                width: double.infinity,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: greySmallText.copyWith(fontSize: 16.0)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}