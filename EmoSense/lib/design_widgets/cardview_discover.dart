import 'package:flutter/material.dart';

import 'package:emosense/design_widgets//font_style.dart';

class MeditationToolCard extends StatelessWidget {
  final String backgroundImage;
  final IconData iconData;
  final String title;
  final String description;
  final VoidCallback? onTap;

  MeditationToolCard({
    required this.backgroundImage,
    required this.iconData,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure children expand horizontally
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
              height: 150.0,
              width: double.infinity,
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      color: Colors.transparent,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        iconData,
                        color: Color(0xFF366021),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: homeSubHeaderText,
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}