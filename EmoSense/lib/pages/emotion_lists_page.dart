import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/model/emotion_data_model.dart';
import 'package:emosense/model/emotion_model.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/model/stress_model.dart';
import 'package:emosense/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class EmotionListPage extends StatefulWidget {
  final DateTime selectedDate;
  final List<EmotionData> emotions;
  final VoidCallback onUpdate;  // Callback to refresh other pages

  EmotionListPage({
    required this.selectedDate,
    required this.emotions,
    required this.onUpdate, // Pass this callback from Home/Calendar pages
  });

  @override
  State<EmotionListPage> createState() => _EmotionListPageState();
}

class _EmotionListPageState extends State<EmotionListPage> {
  int? _editingIndex;
  final TextEditingController _descriptionController = TextEditingController();
  final docId = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      Firebase.initializeApp();
      fetchEmotionsForDate();
    });
  }

  // Function to fetch emotions for the selected date after delete or edit
  Future<void> fetchEmotionsForDate() async {
    final uid = globalUID; // Make sure you have access to the global UID
    final startOfDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

    final emotionSnapshot = await FirebaseFirestore.instance
        .collection('emotionRecords') // Ensure you're using the correct collection name
        .where('uid', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .get();

    List<EmotionData> fetchedEmotions = [];

    if (emotionSnapshot.docs.isNotEmpty) {
      for (var doc in emotionSnapshot.docs) {
        // Get the emotion name as a string
        String emotionName = doc['emotion'] as String;

        // Retrieve the stress level, ensuring it's treated correctly
        String stressLevelString = doc['stressLevel'];
        double stressLevelValue = double.tryParse(stressLevelString) ?? 2.0; // Default to 2.0 if parsing fails

        // Find the corresponding Emotion object from the Emotion class
        Emotion emotion = Emotion.emotions.firstWhere(
              (e) => e.name == emotionName,
          orElse: () => Emotion.emotions.first, // Fallback to the first emotion if not found
        );

        // Find the corresponding StressModel using the double value
        StressModel stressModel = stressModels.firstWhere(
              (s) => s.level == EmotionData.getStressLevelAsString(stressLevelValue),
          orElse: () => stressModels.last,
        );

        // Get the description, providing a default value if null
        String description = doc['description'] as String? ?? '';

        fetchedEmotions.add(
          EmotionData(
            emotion: emotion, // Pass the Emotion object instead of the String
            timestamp: (doc['timestamp'] as Timestamp).toDate(),
            stressLevel: stressModel,
            description: description,
            docId: doc.id, // Include document ID for further operations
          ),
        );
      }
    }


    setState(() {
      widget.emotions.clear(); // Clear the current list
      widget.emotions.addAll(fetchedEmotions); // Update with new data
    });
  }

  Future<void> deleteEmotion(String emotionRecordId) async {
    try {
      print("Attempting to delete emotion with ID: $emotionRecordId"); // Debugging statement
      await FirebaseFirestore.instance
          .collection('emotionRecords')
          .doc(emotionRecordId)
          .delete();

      print("Deleted emotion with ID: $emotionRecordId");

      // Remove the deleted emotion from the list
      setState(() {
        widget.emotions.removeWhere((emotion) => emotion.docId == emotionRecordId);
        // Refresh emotions for the selected date after deletion
        fetchEmotionsForDate();

      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Emotion deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Refresh other pages as well
      widget.onUpdate();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete emotion: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void showDeleteConfirmationDialog(String emotionId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this emotion record?'),
          actions: [
            TextButton(
              onPressed: () async{
                Navigator.pop(context, true); // Close the dialog

              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {  // Make the onPressed async
                Navigator.pop(context, true); // Close the dialog
                deleteEmotion(emotionId); // Perform delete operation
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Function to update emotion description in Firestore and refresh UI
  void updateEmotionDescription(String docId, String newDescription) async {
    try {
      print("Attempting to update description for emotion with ID: $docId");
      // Get the current emotion and stress level from Firestore
      DocumentSnapshot emotionDoc = await FirebaseFirestore.instance
          .collection('emotionRecords')
          .doc(docId)
          .get();

      String currentEmotion = emotionDoc['emotion'];
      String currentStressLevel = emotionDoc['stressLevel'];

      // Create the update map with the current values
      Map<String, dynamic> updatedEmotionRecord = {
        'emotion': currentEmotion, // Keep the existing emotion
        'stressLevel': currentStressLevel, // Keep the existing stress level
        'description': newDescription, // Update the description
      };

      // Update the emotion record in Firestore
      await FirebaseFirestore.instance
          .collection('emotionRecords')
          .doc(docId)
          .update(updatedEmotionRecord);

      print("Updated description for emotion with ID: $docId");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Emotion updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        _editingIndex = null; // Exit edit mode
        // Re-fetch emotions for the selected date after update
        fetchEmotionsForDate();

      });

    } catch (e) {
      print("Error updating emotion: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update emotion: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


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
        title: Container(
          alignment: Alignment.center,
          child: Text(
            'My Emotion',
            style: titleBlack,
          ),
        ),
        actions: [
          Container(width: 48),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 8.0),
                child: Text(
                  '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                  style: titleBlack.copyWith(fontSize: 15),
                ),
              ),
            ),
            ListView.builder(
              itemCount: widget.emotions.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final emotionData = widget.emotions[index];
                final stressLevelColor = emotionData.stressLevel.containerColor;
                final DateTime timestamp = emotionData.timestamp;
                final docId = emotionData.docId;
                print("Stress Level at emotion lists page 1st : ${emotionData.stressLevel.level}"); // Debugging statement

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
                            // Emotion Container
                            Container(
                              height: screenHeight * 0.1,
                              width: screenWidth * 0.4,
                              decoration: BoxDecoration(
                                color: emotionData.emotion.containerColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: screenHeight * 0.21,
                                    width: screenWidth * 0.21,
                                    child: Image.asset(emotionData.emotion.assetPath),
                                  ),
                                  SizedBox(width: 4.0),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12.0),
                                          child: Text("Emotion",
                                            style: greySmallText.copyWith(fontSize: 13),
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
                            // Stress Container
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
                                    child: Image.asset(emotionData.stressLevel.assetPath),
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
                        // Description and Edit Mode (No Border)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 4.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _editingIndex == index
                                    ? TextField(
                                  controller: _descriptionController..text = emotionData.description,
                                  style: greySmallText.copyWith(fontSize: 14, color: AppColors.textColorBlack),
                                  maxLines: null,
                                  decoration: InputDecoration.collapsed(
                                    hintText: '', // No hint or border
                                  ),
                                )
                                    : Text(
                                  emotionData.description,
                                  style: greySmallText.copyWith(fontSize: 14),
                                  maxLines: null,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Timestamp, Edit, and Delete Buttons
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, right: 12.0),
                                  child: Text(
                                    timestamp.toLocal().toString().split(' ')[1].substring(0, 5),
                                    style: greySmallText.copyWith(fontSize: 12),
                                  ),
                                ),
                                // Edit Button
                                GestureDetector(
                                  onTap: () {
                                    if (_editingIndex == index) {
                                      print("Updating description for emotion with ID: ${emotionData.docId}"); // Debugging statement
                                      updateEmotionDescription(emotionData.docId, _descriptionController.text);
                                    } else {
                                      setState(() {
                                        print("Editing description for emotion with ID: ${emotionData.docId}"); // Debugging statement
                                        _editingIndex = index;
                                        _descriptionController.text = emotionData.description; // Pre-fill the controller
                                      });
                                    }
                                  },
                                  child: Icon(
                                    _editingIndex == index ? Icons.check : Icons.edit_note,
                                    color: AppColors.textColorBlack,
                                    size: 25.0,
                                  ),
                                ),
                                // Delete Button
                                GestureDetector(
                                  onTap: () {
                                    showDeleteConfirmationDialog(emotionData.docId);
                                  },
                                  child: Icon(
                                    Icons.delete_forever,
                                    color: AppColors.textColorBlack,
                                    size: 25.0,
                                  ),
                                ),
                              ],
                            ),
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
