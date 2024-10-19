import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/custom_loading_button.dart';
import 'package:emosense/main.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:emosense/api_services/spotify_services.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';

class EditEmotionGenreSurveyPage extends StatefulWidget {
  final SpotifyService spotifyService;
  final List<String> selectedGenres;

  EditEmotionGenreSurveyPage({required this.spotifyService, required this.selectedGenres});

  @override
  _EditEmotionGenreSurveyPageState createState() => _EditEmotionGenreSurveyPageState();
}

class _EditEmotionGenreSurveyPageState extends State<EditEmotionGenreSurveyPage> {
  late Map<String, String?> emotionGenreMap = {
    'Happy': null,
    'Sad': null,
    'Angry': null,
    'Disgust': null,
    'Fear': null,
    'Neutral': null,
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavouriteEmotionGenres(); // Fetch previous selections
  }

  void fetchFavouriteEmotionGenres() async {
    try {
      await FirebaseFirestore.instance
          .collection('preferences')
          .where('uid', isEqualTo: globalUID)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          List<dynamic> fetchedEmotionGenreList = List<dynamic>.from(data['emotionGenreMap']);

          setState(() {
            emotionGenreMap = {
              'Happy': fetchedEmotionGenreList[0] ?? null, // 0
              'Sad': fetchedEmotionGenreList[1] ?? null,   // 1
              'Angry': fetchedEmotionGenreList[2] ?? null, // 2
              'Disgust': fetchedEmotionGenreList[3] ?? null, // 3
              'Fear': fetchedEmotionGenreList[4] ?? null,   // 4
              'Neutral': fetchedEmotionGenreList[5] ?? null, // 5
            };
            isLoading = false; // Hide loading indicator after data is fetched
          });

          print("Emotion Genre List from db: $fetchedEmotionGenreList");
        } else {
          setState(() {
            isLoading = false; // Hide loading if no data is found
          });
        }
      });
    } catch (e) {
      print("Error fetching favourite emotion genres: $e");
      setState(() {
        isLoading = false; // Hide loading in case of an error
      });
    }
  }

  Future<void> savePreferencesToFirebase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Find the document to update
      await firestore
          .collection('preferences')
          .where('uid', isEqualTo: globalUID)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          // Convert the emotionGenreMap to a list before saving
          List<String?> emotionGenreList = [
            emotionGenreMap['Happy'],
            emotionGenreMap['Sad'],
            emotionGenreMap['Angry'],
            emotionGenreMap['Disgust'],
            emotionGenreMap['Fear'],
            emotionGenreMap['Neutral'],
          ];

          // Update the existing document
          snapshot.docs.first.reference.update({
            'selectedGenres': widget.selectedGenres,
            'emotionGenreMap': emotionGenreList, // Save as a list
          });
          print("Preferences updated successfully!");
        }
      });
    } catch (e) {
      print("Error updating preferences: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.downBackgroundColor,
      body: isLoading
          ? Center(child: CustomLoadingIndicator()) // Show loading indicator while fetching data
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_outlined, color: AppColors.darkLogoColor),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: Text(
                    "Select genre you like for each emotion",
                    style: ProfileTitleText,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  ...emotionGenreMap.keys.map((emotion) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emotion,
                          style: titleBlack.copyWith(color: AppColors.darkPurpleColor, fontSize: 16),
                        ),
                        Column(
                          children: widget.selectedGenres.map((genre) {
                            return RadioListTile<String>(
                              title: Text(genre, style: textBlackNormal.copyWith(fontSize: 17)),
                              value: genre,
                              groupValue: emotionGenreMap[emotion],
                              onChanged: (value) {
                                setState(() {
                                  emotionGenreMap[emotion] = value;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPurpleColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        if (emotionGenreMap.values.any((genre) => genre == null)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select a genre for each emotion.')),
                          );
                          return;
                        }

                        savePreferencesToFirebase(); // Update preferences in Firebase
                        // Show updated snackbar for 2 seconds
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Preferences updated successfully!'),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // Navigate back to the HomePage and set the selected index to 4 (Profile Page)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage(selectedIndex: 4)),
                        );
                      },
                      child: Text(
                        "Next",
                        style: whiteText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
