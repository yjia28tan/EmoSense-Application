import 'package:emosense/api_services/spotify_services.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/custom_loading_button.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/main.dart';
import 'package:emosense/pages/music_recommends.dart';
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
  List<Track> tracksRecommended = []; // Updated to hold Track objects
  final spotifyService = SpotifyService();
  Map<String, String?>? emotionGenreMap;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserPreferences(globalUID!);
  }

// Method to get user preferences from Firestore
  Future<Map<String, dynamic>?> getUserPreferences(String uid) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('preferences')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Fetch data and ensure proper types
        final data = querySnapshot.docs.first.data();
        if (data['emotionGenreMap'] is List) {
          print("Preferences Data: $data");
          return data; // return the whole document data if needed
        }
      }
    } catch (e) {
      print("Error fetching preferences: $e");
    }
    return null;
  }


  Future<void> _getSongandSaveEntry() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      // Authenticate with Spotify API
      await spotifyService.authenticate();

      // Fetch user preferences to get the emotionGenreMap
      final preferences = await getUserPreferences(globalUID!);

      if (preferences != null) {
        List<String> emotionGenreMap = List<String>.from(
            preferences['emotionGenreMap']);
        Map<String, int> emotionIndexMap = {
          'Happy': 0,
          'Sad': 1,
          'Angry': 2,
          'Disgust': 3,
          'Fear': 4,
          'Neutral': 5,
        };

        String? genreForDetectedEmotion = emotionGenreMap[emotionIndexMap[widget
            .detectedEmotion] ?? 0];

        String? query = widget.detectedEmotion + ' ' +  genreForDetectedEmotion;

        print('\n-----------------------------Query: $query\n');

        final playlists = await spotifyService.searchPlaylists(query);

        // Fetch tracks from the playlists
        tracksRecommended =
        await spotifyService.fetchTracksFromPlaylists(playlists);

        // Prepare tracks to save to Firestore
        final List<Map<String, dynamic>> tracksForFirestore = tracksRecommended
            .map((track) {
          return {
            'id': track.id,
            'name': track.name,
            'artist': track.artist,
            'album': track.album,
            'imageUrl': track.imageUrl,
            'spotifyUrl': track.spotifyUrl,
          };
        }).toList();

        final data = {
          'emotion': widget.detectedEmotion,
          'stressLevel': widget.stressLevel,
          'description': _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          'timestamp': Timestamp.now(),
          'tracks': tracksForFirestore,
          'uid': globalUID,
        };

        await FirebaseFirestore.instance.collection('emotionRecords').add(
            data);

        // Navigate to the RecommendedSongsPage after saving
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              RecommendedSongsPage(songs: tracksRecommended)),
        );
      } else {
        print("Emotion genre map is not available.");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 35.0, left: 18.0, right: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'What’s on your mind?',
                        style: titleBlack,
                      ),
                    ),
                  ),
                  SizedBox(height: 125),
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.6,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.textColorBlack, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Write your thoughts here...',
                          hintStyle: greySmallText.copyWith(fontSize: 16),
                          alignLabelWithHint: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 16, bottom: 2),
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
                          onPressed: _getSongandSaveEntry,
                          child: Icon(
                            Icons.check,
                            color: AppColors.darkPurpleColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Positioned image at the top right
          if (!isLoading) // Display the image only when not loading
            Positioned(
              top: -85, // Adjust this value to change vertical position
              right: -10, // Adjust this value to change horizontal position
              child: Image.asset(
                'assets/write.png',
                width: screenWidth * 0.60, // Adjust width as needed
                height: screenHeight * 0.60, // Adjust height as needed
              ),
            ),
          if (isLoading) // Display loading indicator when loading
            Container(
              color: Color(0xFFF2F2F2),
              child: Center(
                child: CustomLoadingIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
