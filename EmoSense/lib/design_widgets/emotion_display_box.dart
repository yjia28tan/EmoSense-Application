import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodDisplay extends StatelessWidget {
  final Color moodColor;
  final IconData moodIcon;
  final String emotionText;
  final DateTime time;

  MoodDisplay({
    required this.moodColor,
    required this.moodIcon,
    required this.emotionText,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: 150.0, // Set a fixed width for horizontal scrolling
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: moodColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8.0),
        // border: Border.all(color: moodColor, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            moodIcon,
            size: 50.0,
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emotionText,
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 16.0,
                    // fontWeight: FontWeight.bold,
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
