import 'package:emosense/api_services/spotify_services.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/main.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:emosense/pages/song_recommends.dart';
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

  // get favorite genres and artists from Firestore
  Future<Map<String, dynamic>?> getUserPreferences(String uid) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('preferences')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
    } catch (e) {
      print("Error fetching preferences: $e");
    }
    return null;
  }


  Future<void> _getSongandSaveEntry() async {
    // Authenticate with Spotify API
    await spotifyService.authenticate();

    // Search playlists based on the user's current emotion, favourite genre, etc.
    final playlists = await spotifyService.searchPlaylists(widget.detectedEmotion);

    // Fetch tracks from the playlists
    tracksRecommended = await spotifyService.fetchTracksFromPlaylists(playlists);

    // Display or use the recommended tracks
    for (var track in tracksRecommended) {
      print('Track: ${track.name} : ${track.artist}');
    }

    // Convert tracks to a list of maps to save to Firestore
    final List<Map<String, dynamic>> tracksForFirestore = tracksRecommended.map((track) {
      return {
        'id': track.id,
        'name': track.name,
        'artist': track.artist,
        'album': track.album,
        'imageUrl': track.imageUrl,
        'spotifyUrl': track.spotifyUrl, // Save the Spotify URL
      };
    }).toList();

    // Prepare data to save
    final data = {
      'emotion': widget.detectedEmotion,
      'stressLevel': widget.stressLevel,
      'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      'timestamp': Timestamp.now(),
      'tracks': tracksForFirestore, // Save tracks as a list of maps
      'uid': globalUID,
    };

    // Save to Firestore
    await FirebaseFirestore.instance.collection('emotion records').add(data);

    // Navigate to the recommended songs page and display the songs recommended
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecommendedSongsPage(songs: tracksRecommended)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: SingleChildScrollView(
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
                        _getSongandSaveEntry();
                      },
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
    );
  }
}
