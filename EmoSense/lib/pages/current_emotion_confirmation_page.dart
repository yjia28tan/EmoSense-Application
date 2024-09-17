import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:flutter/material.dart';

class EmotionConfirmationPage extends StatefulWidget {
  final String detectedEmotion;

  EmotionConfirmationPage({required this.detectedEmotion});

  @override
  _EmotionConfirmationPageState createState() => _EmotionConfirmationPageState();
}

class _EmotionConfirmationPageState extends State<EmotionConfirmationPage> {
  late String detectedEmotion;

  @override
  void initState() {
    super.initState();
    // Initialize detectedEmotion from the passed value
    detectedEmotion = widget.detectedEmotion;
  }

  void _showEmotionSelectionSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    String? selectedEmotion = detectedEmotion; // Set initial selection to the detected emotion

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to expand fully
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: screenHeight * 0.7,
              color: AppColors.lightBackgroundColor, // Set background color
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // ListTile options for each emotion
                          ListTile(
                            leading: Icon(
                              Icons.sentiment_very_satisfied,
                              color: selectedEmotion == 'Happy' ? AppColors.lightLogoColor : AppColors.darkPurpleColor,
                            ),
                            title: Text('Happy', style: TextStyle(color: AppColors.lightLogoColor)),
                            onTap: () {
                              setState(() {
                                selectedEmotion = 'Happy';
                              });
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.sentiment_satisfied,
                              color: selectedEmotion == 'Neutral' ? AppColors.lightLogoColor : AppColors.darkPurpleColor,
                            ),
                            title: Text('Neutral', style: TextStyle(color: AppColors.lightLogoColor)),
                            onTap: () {
                              setState(() {
                                selectedEmotion = 'Neutral';
                              });
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.sentiment_neutral,
                              color: selectedEmotion == 'Fear' ? AppColors.lightLogoColor : AppColors.darkPurpleColor,
                            ),
                            title: Text('Fear', style: TextStyle(color: AppColors.lightLogoColor)),
                            onTap: () {
                              setState(() {
                                selectedEmotion = 'Fear';
                              });
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.sentiment_dissatisfied,
                              color: selectedEmotion == 'Disgust' ? AppColors.lightLogoColor : AppColors.darkPurpleColor,
                            ),
                            title: Text('Disgust', style: TextStyle(color: AppColors.lightLogoColor)),
                            onTap: () {
                              setState(() {
                                selectedEmotion = 'Disgust';
                              });
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.sentiment_satisfied,
                              color: selectedEmotion == 'Surprise' ? AppColors.lightLogoColor : AppColors.darkPurpleColor,
                            ),
                            title: Text('Surprise', style: TextStyle(color: AppColors.lightLogoColor)),
                            onTap: () {
                              setState(() {
                                selectedEmotion = 'Surprise';
                              });
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: selectedEmotion == 'Angry' ? AppColors.lightLogoColor : AppColors.darkPurpleColor,
                            ),
                            title: Text('Angry', style: TextStyle(color: AppColors.lightLogoColor)),
                            onTap: () {
                              setState(() {
                                selectedEmotion = 'Angry';
                              });
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: selectedEmotion == 'Sad' ? AppColors.lightLogoColor : AppColors.darkPurpleColor,
                            ),
                            title: Text('Sad', style: TextStyle(color: AppColors.lightLogoColor)),
                            onTap: () {
                              setState(() {
                                selectedEmotion = 'Sad';
                              });
                            },
                          ),
                        ],
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
                            borderRadius: BorderRadius.circular(100), // Rounded corners
                          ),
                        ),
                        onPressed: () {
                          if (selectedEmotion != null) {
                            setState(() {
                              detectedEmotion = selectedEmotion!;
                            });
                            print('Confirmed emotion: $detectedEmotion');
                            Navigator.pop(context); // Close the modal bottom sheet
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
                                        Navigator.of(context).pop(); // Close the dialog
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.downBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_satisfied, size: 100),
            SizedBox(height: 20),
            Text(
              'Is "$detectedEmotion" your current emotion?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the description page if the emotion is correct
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         EmotionDescriptionPage(selectedEmotion: detectedEmotion),
                //   ),
                // );
              },
              child: Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                // Show bottom sheet to select a different emotion
                _showEmotionSelectionSheet(context);
              },
              child: Text('No, choose another'),
            ),
          ],
        ),
      ),
    );
  }
}
