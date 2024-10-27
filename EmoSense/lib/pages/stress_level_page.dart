import 'package:emosense/model/stress_model.dart'; // Import the new stress model
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
  double _currentStressLevel = 2;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Stack(
        children: [
          // Background image or logo (stacked at the bottom layer)
          Positioned(
            bottom: -150,
            left: -25,
            child: Image.asset(
              'assets/stress.png',
              width: screenWidth * 0.6,
              height: screenHeight * 0.6,
            ),
          ),
          // Main content of the page (stacked above the background)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0, left: 25, right: 25, bottom: 8),
                child: Text(
                  'How would you rate your stress level?',
                  style: titleBlack,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 20, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Display the stress levels in a column
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(stressModels.length, (index) {
                        final stress = stressModels[index];
                        return Container(
                          height: screenHeight * 0.12,
                          width: 198,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stress.level,
                                style: titleBlack.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                stress.description,
                                style: greySmallText.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                              Text(stress.description2,
                                style: greySmallText.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Container(
                        height: screenHeight * 0.6,
                        width: 30,
                        child: RotatedBox(
                          quarterTurns: 3, // Rotates the slider 90 degrees counterclockwise
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 5, // Adjust the height of the slider track to make it slim
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 2),
                              overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
                              activeTrackColor: stressModels[_currentStressLevel.toInt()].color, // Set active track color based on current stress level
                              inactiveTrackColor: Colors.grey,
                              thumbColor: stressModels[_currentStressLevel.toInt()].color, // Set thumb color based on current stress level
                            ),
                            child: Slider(
                              value: _currentStressLevel,
                              min: 0,
                              max: 4,
                              divisions: 4,
                              onChanged: (double value) {
                                setState(() {
                                  _currentStressLevel = value;
                                  print(_currentStressLevel);
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Display the stress icons as images in a column
                    Column(
                      children: List.generate(stressModels.length, (index) {
                        final stress = stressModels[index];
                        return Container(
                          height: screenHeight * 0.137,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                stress.assetPath, // Use the asset path for the icon image
                                width: 100,
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
                        color: AppColors.darkPurpleColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
