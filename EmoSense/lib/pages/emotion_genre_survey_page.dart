import 'package:emosense/pages/artists_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:emosense/api_services/spotify_services.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';

class EmotionGenreSurveyPage extends StatefulWidget {
  final SpotifyService spotifyService;
  final List<String> selectedGenres;

  EmotionGenreSurveyPage({required this.spotifyService, required this.selectedGenres});

  @override
  _EmotionGenreSurveyPageState createState() => _EmotionGenreSurveyPageState();
}

class _EmotionGenreSurveyPageState extends State<EmotionGenreSurveyPage> {
  final Map<String, String?> emotionGenreMap = {
    'Happy': null, // 0
    'Sad': null, // 1
    'Angry': null, // 2
    'Disgust': null, // 3
    'Fear': null, // 4
    'Neutral': null, // 5
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.downBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            Row(
              children: [

                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_outlined,
                        color: AppColors.textColorBlack),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                Expanded( // Use Expanded or Flexible here
                  child: Text(
                    "Select genre you like for each emotion",
                    style: titleBlack,
                    textAlign: TextAlign.center,
                    maxLines: 2, // Allow maximum of 2 lines
                    overflow: TextOverflow.ellipsis, // Show ellipsis if it overflows
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
                              title: Text(genre,
                                  style: textBlackNormal.copyWith(fontSize: 17)
                              ),
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
                        SizedBox(height:10),
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
                        minimumSize: Size(double.infinity, 50), // Full-width button
                      ),
                      onPressed: () {
                        // Only proceed if each emotion has a selected genre
                        if (emotionGenreMap.values.any((genre) => genre == null)) {
                          // Show a message if the user hasn't selected all genres
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select a genre for each emotion.')),
                          );
                          return;
                        }

                        // Filter out null values and convert to List<String>
                        List<String> selectedEmotionGenres = emotionGenreMap.values
                            .where((genre) => genre != null)
                            .cast<String>()
                            .toList();

                        // Navigate to the artist selection page with the selected genres and filtered emotion genres
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArtistSelectionPage(
                              spotifyService: widget.spotifyService, // Pass the SpotifyService instance
                              selectedGenres: widget.selectedGenres,
                              emotionGenreMap: selectedEmotionGenres, // Pass the filtered list
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
