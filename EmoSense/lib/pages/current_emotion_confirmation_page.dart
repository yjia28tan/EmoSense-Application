import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/model/emotion_model.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/pages/stress_level_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class EmotionConfirmationPage extends StatefulWidget {
  final String detectedEmotion;

  EmotionConfirmationPage({required this.detectedEmotion});

  @override
  _EmotionConfirmationPageState createState() => _EmotionConfirmationPageState();
}

class _EmotionConfirmationPageState extends State<EmotionConfirmationPage> {
  late String detectedEmotion;
  String? detectedEmotionAssetPath;
  Color? detectedEmotionColor;

  @override
  void initState() {
    super.initState();
    // Initialize detectedEmotion and related properties from the passed value
    detectedEmotion = widget.detectedEmotion;
    _updateEmotionAssetAndColor(detectedEmotion);
  }

  // Helper function to update image asset and color based on the emotion name
  void _updateEmotionAssetAndColor(String emotionName) {
    final selectedEmotionData = emotions.firstWhere(
          (emotion) => emotion.name == emotionName,
      orElse: () => emotions.first,
    );
    setState(() {
      detectedEmotionAssetPath = selectedEmotionData.assetPath; // Update image asset path
      detectedEmotionColor = selectedEmotionData.color; // Update color
    });
  }

  // Function to display the emotion selection sheet
  void _showEmotionSelectionSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    String? selectedEmotion = detectedEmotion;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(50.0), // Apply curve to the top only
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: screenHeight * 0.7,
              decoration: BoxDecoration(
                color: AppColors.downBackgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.0), // Apply the same curve here
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Select your current emotion',
                      style: titleBlack,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: emotions.map((emotion) {
                          bool isSelected = selectedEmotion == emotion.name;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0), // Spacing between items
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedEmotion = emotion.name;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.0), // Curved borders
                                  border: Border.all(
                                    color: isSelected ? emotion.color : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      emotion.assetPath, // Display emotion image
                                      width: 60,
                                      height: 60,
                                    ),
                                    SizedBox(width: 20.0), // Space between icon and text
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        emotion.name,
                                        style: GoogleFonts.leagueSpartan(
                                          color: isSelected ? AppColors.darkPurpleColor : Colors.black54,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // Confirmation button at the bottom
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                    child: Container(
                      height: screenHeight * 0.07,
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text('Confirm', style: whiteText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPurpleColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onPressed: () {
                          if (selectedEmotion != null) {
                            setState(() {
                              detectedEmotion = selectedEmotion!;
                              _updateEmotionAssetAndColor(detectedEmotion); // Update icon and color based on new selection
                            });
                            Navigator.pop(context);
                          } else {
                            // Show dialog if no emotion is selected
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('No emotion selected'),
                                  content: Text('Please select an emotion before proceeding.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    // Show confirmation dialog when back button is pressed
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Exit'),
        content: Text('Emotion will not be added. Do you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Don't pop
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              setState(() {
                detectedEmotion = '';
              });
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    return shouldPop ?? false; // Fallback to false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.25),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Your current emotion detected is',
                  style: titleBlack,
                ),
              ),
              Text(
                ' "$detectedEmotion" ',
                style: titleBlack.copyWith(fontSize: 22),
              ),
              SizedBox(height: 20),
              detectedEmotionAssetPath != null
                  ? Image.asset(
                detectedEmotionAssetPath!, // Display the detected emotion image
                width: 200,
                height: 200,
              )
                  : SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  width: screenWidth * 0.75,
                  height: screenHeight * 0.07,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPurpleColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: () {
                      _showEmotionSelectionSheet(context);
                    },
                    child: Text('Not my current emotion', style: whiteText),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 20),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.upBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StressLevelPage(detectedEmotion: detectedEmotion),
                          ),
                        );
                      },
                      child: Icon(Icons.arrow_forward_rounded, color: AppColors.darkPurpleColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
