import 'package:flutter/material.dart';
import 'package:emosense/api_services/spotify_services.dart';

// This page will collect user preferences for different emotions
class PreferencesSurveyGenre extends StatefulWidget {
  static String routeName = '/PreferencesSurveyGenre';

  @override
  _PreferencesSurveyGenreState createState() => _PreferencesSurveyGenreState();
}

class _PreferencesSurveyGenreState extends State<PreferencesSurveyGenre> {
  // These lists will store the user's selections
  List<String> happyGenres = [];
  List<String> sadGenres = [];
  List<String> angryGenres = [];
  List<String> neutralGenres = [];
  List<String> fearGenres = [];
  List<String> disgustGenres = [];

  // called Fetch List of available genres function from SpotifyService class (API)
  List<String> availableGenres = SpotifyService().fetchGenres() as List<String>;

  print(availableGenres) {
    // TODO: implement print
    throw UnimplementedError();
  }

  // Function to build genre selection bubbles for a specific emotion
  Widget _buildGenreSelection(
      String emotion, List<String> selectedGenres, Function(List<String>) onSelectionChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What genres do you listen to when you feel $emotion?'),
        Wrap(
          spacing: 8.0,
          children: availableGenres.map((genre) {
            bool isSelected = selectedGenres.contains(genre);
            return ChoiceChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedGenres.add(genre);
                  } else {
                    selectedGenres.remove(genre);
                  }
                  onSelectionChanged(selectedGenres);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Function to handle form submission
  void _submitPreferences() {
    // Save the user preferences in your backend or Firestore
    // For now, just print the selections to console
    print("Happy Genres: $happyGenres");
    print("Sad Genres: $sadGenres");
    print("Angry Genres: $angryGenres");
    print("Neutral Genres: $neutralGenres");
    print("Fear Genres: $fearGenres");

    // Navigate to the next page or show a success message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences Survey'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGenreSelection(
              'Happy',
              happyGenres,
                  (selectedGenres) => happyGenres = selectedGenres,
            ),
            SizedBox(height: 16.0),
            _buildGenreSelection(
              'Sad',
              sadGenres,
                  (selectedGenres) => sadGenres = selectedGenres,
            ),
            SizedBox(height: 16.0),
            _buildGenreSelection(
              'Angry',
              angryGenres,
                  (selectedGenres) => angryGenres = selectedGenres,
            ),
            SizedBox(height: 16.0),
            _buildGenreSelection(
              'Neutral',
              neutralGenres,
                  (selectedGenres) => neutralGenres = selectedGenres,
            ),
            SizedBox(height: 16.0),
            _buildGenreSelection(
              'Fear',
              fearGenres,
                  (selectedGenres) => fearGenres = selectedGenres,
            ),
            SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: _submitPreferences,
                child: Text('Submit Preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
