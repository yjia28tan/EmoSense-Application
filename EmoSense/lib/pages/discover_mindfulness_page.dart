import 'package:audioplayers/audioplayers.dart';
import 'package:emosense/api_services/spotify_services.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/podcast_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MindfulnessGuideContent extends StatefulWidget {
  @override
  State<MindfulnessGuideContent> createState() => _MindfulnessGuideContentState();
}

class _MindfulnessGuideContentState extends State<MindfulnessGuideContent> {
  final SpotifyService spotifyService = SpotifyService();
  Map<String, dynamic>? mindfulness_podcastData;

  @override
  void initState() {
    super.initState();
    _fetchPodcastData();
  }

  Future<void> _fetchPodcastData() async {
    try {
      await spotifyService.authenticate(); // Authenticate first
      mindfulness_podcastData = await spotifyService.getPodcastDetails('50yOGRLSNwrA5mDO2g5gt8'); // Replace with actual podcast ID
      setState(() {});
    } catch (error) {
      print('Error fetching podcast data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.textFieldColor,
      body: SingleChildScrollView( // Wrap the body with SingleChildScrollView
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  child: Image.asset(
                    'assets/discover/meditation.jpg',
                    height: 200.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and duration
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Mindfulness meditations',
                      style: titleBlack.copyWith(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Description
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mindfulness meditation is a mental training practice that teaches you to slow down racing thoughts, '
                          'let go of negativity, and calm both your mind and body.',
                      style: greySmallText.copyWith(fontSize: 16.0),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            // Additional content
            SizedBox(height: screenHeight * 0.025),
            Text(
              'Here are the podcast sessions to help you get started on mindfulness meditation: \n',
              style: greySmallText.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            ),
            if (mindfulness_podcastData != null) // Check if podcast data is available
              PodcastCard(
                title: 'Mindful Meditations by Mindful.org',
                description: mindfulness_podcastData!['description'],
                imageUrl: mindfulness_podcastData!['imageUrl'],
                spotifyLink: mindfulness_podcastData!['externalUrl'],
                youtubeLink: 'https://www.youtube.com/channel/UCXsjej0djMYxtGC3RMHBUvg',
              ),
          ],
        ),
      ),
    );
  }
}
