import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/emotion_data_model.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmotionListPage extends StatelessWidget {
  final DateTime selectedDate;
  final List<EmotionData> emotions; // List of emotions passed to the page

  EmotionListPage({required this.selectedDate, required this.emotions});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.textFieldColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textColorBlack),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.textFieldColor,
        title: Center(
          child: Text(
            'My Emotion',
            style: titleBlack,
          ),
        ),
      ),
      body: SingleChildScrollView( // Make the whole screen scrollable
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 8.0),
                child: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: titleBlack.copyWith(fontSize: 15),
                ),
              ),
            ),
            ListView.builder(
              itemCount: emotions.length,
              shrinkWrap: true, // Use shrinkWrap to prevent unbounded height
              physics: NeverScrollableScrollPhysics(), // Disable scrolling for inner ListView
              itemBuilder: (context, index) {
                final emotionData = emotions[index];
                final stressLevelColor = emotionData.stressLevel.containerColor;
                final DateTime timestamp = emotionData.timestamp;
                print('Timestamp: $timestamp');
                print('Emotion: ${emotionData.emotion.name}, Stress: ${emotionData.stressLevel.level}');
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 4.0),
                  child: Container(
                    height: screenHeight * 0.5,
                    margin: EdgeInsets.all(7),
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: screenHeight * 0.1,
                              width: screenWidth * 0.4,
                              decoration: BoxDecoration(
                                color: emotionData.emotion.containerColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  // Set the size of the icon
                                  SizedBox(
                                    height: screenHeight * 0.21,
                                    width: screenWidth * 0.21,
                                    child: Image.asset(emotionData.emotion.assetPath), // Retrieve emotion icon
                                  ),
                                  SizedBox(width: 4.0),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12.0),
                                          child: Text("Emotion",
                                            style: greySmallText.copyWith(fontSize: 13, fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                        Text(
                                          emotionData.emotion.name,
                                          style: titleBlack.copyWith(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: screenHeight * 0.1,
                              width: screenWidth * 0.4,
                              decoration: BoxDecoration(
                                color: stressLevelColor.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: screenHeight * 0.1,
                                    width: screenHeight * 0.1,
                                    child: Image.asset(emotionData.stressLevel.assetPath), // Retrieve stress icon
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: Text("Stress",
                                          style: greySmallText.copyWith(fontSize: 13),
                                        ),
                                      ),
                                      Text(
                                        emotionData.stressLevel.level,
                                        style: titleBlack.copyWith(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Expanded(
                          child: SingleChildScrollView( // Make the description text scrollable
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 4.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  emotionData.description,
                                  style: greySmallText.copyWith(fontSize: 14),
                                  maxLines: null, // Allow text to take multiple lines
                                  overflow: TextOverflow.visible, // Show all text without clipping
                                ),
                              ),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  // Display only the time
                                  timestamp.toLocal().toString().split(' ')[1].substring(0, 5),
                                  style: greySmallText.copyWith(fontSize: 12),
                                ),
                              ),
                              // Delete icon button
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: IconButton(
                                  icon: Icon(Icons.delete_forever_rounded, color: AppColors.textColorGrey, size: 18.0),
                                  onPressed: () {
                                    print('Delete emotion');

                                    // Delete the emotion from Firestore
                                    // ask for confirmation
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Delete Emotion'),
                                          content: Text('Are you sure you want to delete this emotion?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // Delete the emotion from Firestore
                                                FirebaseFirestore.instance.collection('emotions').doc(emotionData.timestamp.toString()).delete();
                                                Navigator.pop(context);

                                                // Show a snackbar to confirm deletion
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Emotion deleted'),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              },
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                  },
                                ),
                              ),

                            ],
                          ),
                        ),


                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
