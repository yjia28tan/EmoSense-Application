import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/main.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DescriptionPage extends StatefulWidget {
  final String detectedEmotion;
  final String stressLevel;

  DescriptionPage({required this.detectedEmotion, required this.stressLevel});

  @override
  _DescriptionPageState createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _saveEntry() async {
    // Prepare data to save
    final data = {
      'emotion': widget.detectedEmotion,
      'stressLevel': widget.stressLevel,
      'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      'timestamp': Timestamp.now(),
      'uid': globalUID,
    };

    // Save to Firestore
    await FirebaseFirestore.instance.collection('emotion records').add(data);

    // Navigate back or show a confirmation message
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'What’s on your mind?',
                  style: titleBlack,
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: double.infinity,
                height: screenHeight * 0.6,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Write your thoughts here',
                      hintStyle: greySmallText.copyWith(
                        fontSize: 16,
                      ),
                      alignLabelWithHint: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () {
                        // Save the data to the database
                        _saveEntry();
                      },
                      child: Icon(
                          Icons.check,
                          color: AppColors.darkPurpleColor
                      ),
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
