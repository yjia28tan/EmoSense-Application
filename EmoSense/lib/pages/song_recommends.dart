import 'package:emosense/api_services/spotify_services.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendedSongsPage extends StatelessWidget {
  final List<Track> songs;

  RecommendedSongsPage({required this.songs});

  @override
  Widget build(BuildContext context) {
    // Disable back navigation
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
                child: Text(
                  'Song Recommended',
                  style: titleBlack,
                  textAlign: TextAlign.center, // Center align title
                ),
              ),
              // List of songs
              Expanded( // Use Expanded to allow ListView to take available space
                child: ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      leading: Image.network(song.imageUrl),
                      title: Text(song.name),
                      subtitle: Text(song.artist),
                      onTap: () {
                        _showSongDetails(context, song); // Show details on tap
                      },
                    );
                  },
                ),
              ),
              // Button
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
                    // Navigate to the home page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  child: Text(
                    "OK",
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
      ),
    );
  }

  // Method to show song details in a pop-up dialog
  void _showSongDetails(BuildContext context, Track song) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              song.name,
              style: titleBlack
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(song.imageUrl), // Display song image
              SizedBox(height: 10),
              Text("Artist:",
                  style: greySmallText.copyWith(fontSize: 14, fontWeight: FontWeight.bold)
              ),
              Text(song.artist,
                  style: titleBlack.copyWith(fontSize: 14)
              ),
              SizedBox(height: 10),
              Text("Album:",
                  style: greySmallText.copyWith(fontSize: 14, fontWeight: FontWeight.bold)
              ),
              Text(song.album,
                  style: titleBlack.copyWith(fontSize: 14)
              ),
            ],
          ),
          actions: [
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  // Implement Spotify play functionality here
                  _playSongInSpotify(song.id); // Placeholder for Spotify play function
                },
                child: Text("Play in Spotify",
                    style: inkwellText.copyWith(fontSize: 15, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _playSongInSpotify(String trackId) async {
    final String appUrl = 'spotify:track:$trackId'; // Spotify URI
    final String webUrl = 'https://open.spotify.com/track/$trackId'; // Web URL

    // Try to launch the app URL first
    if (await canLaunch(appUrl)) {
      await launch(appUrl);
    } else if (await canLaunch(webUrl)) {
      await launch(webUrl);
    } else {
      print("Could not launch Spotify app or web URL");
    }
  }

  // void _playSongInSpotify(Track song) async {
  //   // Spotify URI for the app
  //   final spotifyUri = song.spotifyUrl;
  //
  //   // Create a Uri object for the Spotify app
  //   final Uri appUri = Uri.parse(spotifyUri);
  //
  //   // Check if the Spotify app can handle the URI
  //   if (await canLaunchUrl(appUri)) {
  //     await launchUrl(appUri); // Launch the app if available
  //   } else {
  //     // If Spotify app is not installed, open the web player
  //     final Uri webUrl = Uri.parse('https://open.spotify.com/track/${song.id}');
  //     if (await canLaunchUrl(webUrl)) {
  //       await launchUrl(webUrl); // Open in web browser
  //     } else {
  //       // Handle the error if neither can be opened
  //       print('Could not launch Spotify app or web URL');
  //     }
  //   }
  // }

}
