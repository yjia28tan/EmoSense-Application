import 'package:emosense/pages/mind_description_page.dart';
import 'package:flutter/material.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';

class StressLevelPage extends StatefulWidget {
  final String detectedEmotion;

  StressLevelPage({required this.detectedEmotion});

  @override
  _StressLevelPageState createState() => _StressLevelPageState();
}

class _StressLevelPageState extends State<StressLevelPage> {
  double _currentStressLevel = 0;

  final List<String> stressLevels = [
    "Extreme", // 4
    "High", // 3
    "Optimal", // 2
    "Moderate", // 1
    "Low", // 0
  ];

  final List<Color> stressColors = [
    Colors.blueAccent,
    Colors.teal,
    Colors.yellowAccent,
    Colors.orange,
    Colors.redAccent,
  ];

  final List<String> stressDescriptions = [
    "Exhaustion, anxiety, burnout",
    "Distracted, fatigue, overwhelm",
    "Confident, in control, productive",
    "Engaged, focused, motivated",
    "Inactive, bored, unchallenged",
  ];

  final List<String> stressDescriptions2 = [
    "\"I can't take this anymore\"",
    "\"I feel anxious & unfocused\"",
    "\"I'm really in the zone\"",
    "\"I feel focused & energized\"",
    "\"I wish I had more to do\"",
  ];

  final List<IconData> stressIcons = [
    Icons.sentiment_very_satisfied,
    Icons.sentiment_satisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_very_dissatisfied,
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 20, right: 20, bottom: 8),
            child: Text(
              'How would you rate your stress level?',
              style: titleBlack,
              maxLines: 2, // Allow the text to wrap into two lines if needed
              overflow: TextOverflow.ellipsis,
              // align the text to the center
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display the stress levels in a row
              Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(stressLevels.length, (index) {
                return Container(
                  // padding: EdgeInsets.symmetric(horizontal: 10),
                  height: screenHeight * 0.15,
                  width: 186,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stressLevels[index],
                          style: titleBlack.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          stressDescriptions[index],
                          style: greySmallText.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          stressDescriptions2[index],
                          style: greySmallText.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                );
                }),
              ),
                Container(
                  height: screenHeight * 0.67,
                  child: RotatedBox(
                    quarterTurns: 3, // Rotates the slider 90 degrees counterclockwise
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 5, // Adjust the height of the slider track to make it slim
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 2),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
                        activeTrackColor: Color(0XFFE8B878),
                        inactiveTrackColor: Colors.grey,
                        thumbColor: Color(0XFFE8B878), // Change thumb color here
                      ),
                      child: Slider(
                        value: _currentStressLevel,
                        min: 0,
                        max: 4,
                        divisions: 4,
                        onChanged: (double value) {
                          setState(() {
                            _currentStressLevel = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                // display the stress icons in a column
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(stressIcons.length, (index) {
                    return Container(
                      height: screenHeight * 0.15,
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                            child: Icon(
                              stressIcons[index],
                              size: 90,
                              color: stressColors[index],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16, bottom: 2),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.upBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100), // Add rounded corners if needed
                    ),
                  ),
                  onPressed: () {
                    // Pass the selected stress level and emotion to the next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DescriptionPage(
                          detectedEmotion: widget.detectedEmotion,
                          stressLevel: _currentStressLevel.toString(),
                        ),
                      ),
                    );
                  },
                  child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.darkPurpleColor
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
