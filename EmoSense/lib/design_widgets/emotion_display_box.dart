import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class EmotionDisplay extends StatelessWidget {
  final Color emotionContainerColor;
  final Image emotionIcon; // This already holds the asset image.
  final String emotionText;
  final DateTime time;

  EmotionDisplay({
    required this.emotionContainerColor,
    required this.emotionIcon,
    required this.emotionText,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: 150.0, // Set a fixed width for horizontal scrolling
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
      decoration: BoxDecoration(
        color: emotionContainerColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // set the size of the icon
          SizedBox(
            height: screenHeight * 0.1,
            width: screenHeight * 0.1,
            child: emotionIcon,
          ),
          SizedBox(width: 4.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emotionText,
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 16.0,
                    color: AppColors.textColorBlack,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: greySmallText.copyWith(fontSize: screenHeight * 0.015),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
