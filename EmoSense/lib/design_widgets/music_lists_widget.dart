import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MusicRecommendedLists extends StatelessWidget {
  final String musicImage;
  final String musicTitle;
  final String artist;
  final String trackId;

  MusicRecommendedLists({
    required this.musicImage,
    required this.musicTitle,
    required this.artist,
    required this.trackId,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    void _playSongInSpotify(String trackId) async {
      final String appUrl = 'spotify:track:$trackId'; // Spotify URI
      final String webUrl = 'https://open.spotify.com/track/$trackId'; // Web URL

      if (await canLaunch(appUrl)) {
        await launch(appUrl);
      } else if (await canLaunch(webUrl)) {
        await launch(webUrl);
      } else {
        print("Could not launch Spotify app or web URL");
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
      child: Container(
        height: screenHeight * 0.12, // Set a fixed height for each track
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppColors.whiteColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              height: screenHeight * 0.1,
              width: screenHeight * 0.1,
              child: Image.network(
                musicImage,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 4.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    musicTitle,
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 14.0,
                      color: AppColors.textColorBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    artist,
                    style: greySmallText.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Play button
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  _playSongInSpotify(trackId); // Call the method to play the song
                },
                child: Container(
                  height: screenHeight * 0.05,
                  width: screenHeight * 0.05, // Fixed width
                  decoration: BoxDecoration(
                    color: AppColors.darkLogoColor,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: AppColors.darkPurpleColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
