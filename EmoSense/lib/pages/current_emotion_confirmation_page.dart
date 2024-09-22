import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/emotion_lists.dart'; // Contains emotions with icon and color data
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/pages/stress_level_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmotionConfirmationPage extends StatefulWidget {
  final String detectedEmotion;

  EmotionConfirmationPage({required this.detectedEmotion});

  @override
  _EmotionConfirmationPageState createState() => _EmotionConfirmationPageState();
}

class _EmotionConfirmationPageState extends State<EmotionConfirmationPage> {
  late String detectedEmotion;
  IconData? detectedEmotionIcon;
  Color? detectedEmotionColor;

  @override
  void initState() {
    super.initState();
    // Initialize detectedEmotion and related properties from the passed value
    detectedEmotion = widget.detectedEmotion;
    _updateEmotionIconAndColor(detectedEmotion);
  }

  // Helper function to update icon and color based on the emotion name
  void _updateEmotionIconAndColor(String emotionName) {
    final selectedEmotionData =
    emotions.firstWhere((emotion) => emotion.name == emotionName, orElse: () => emotions.first);
    setState(() {
      detectedEmotionIcon = selectedEmotionData.icon;
      detectedEmotionColor = selectedEmotionData.color;
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
              height: screenHeight * 0.65,
              decoration: BoxDecoration(
                color: AppColors.lightLogoColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.0), // Apply the same curve here
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: emotions.map((emotion) {
                          bool isSelected = selectedEmotion == emotion.name;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0), // Spacing between items
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedEmotion = emotion.name;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? emotion.color : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.0), // Curved borders
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                                padding: EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      emotion.icon,
                                      color: isSelected ? Colors.white : emotion.color,
                                    ),
                                    SizedBox(width: 16.0), // Space between icon and text
                                    Text(
                                      emotion.name,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : emotion.color,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
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
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      height: screenHeight * 0.07,
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
                              _updateEmotionIconAndColor(detectedEmotion); // Update icon and color based on new selection
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
        content: Text('Emotion will not added. Do you want to exit?'),
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
                  'Your current mood detected is',
                  style: titleBlack,
                ),
              ),
              Text(
                ' "$detectedEmotion" ',
                style: titleBlack.copyWith(fontSize: 22),
              ),
              SizedBox(height: 20),
              Icon(
                detectedEmotionIcon,
                size: 100,
                color: detectedEmotionColor,
              ),
              SizedBox(height: screenHeight * 0.05),
              Padding(
                padding: const EdgeInsets.all(25.0),
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
                    child: Text('Not my current mood', style: whiteText),
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