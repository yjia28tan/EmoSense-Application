import 'package:audioplayers/audioplayers.dart';
import 'package:emosense/api_services/spotify_services.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/podcast_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SleepingGuideContent extends StatefulWidget {
  @override
  State<SleepingGuideContent> createState() => _SleepingGuideContentState();
}

class _SleepingGuideContentState extends State<SleepingGuideContent> {
  final SpotifyService spotifyService = SpotifyService();
  List<Map<String, dynamic>> sleepingPodcasts = []; // List to hold podcast data

  @override
  void initState() {
    super.initState();
    _fetchPodcastData();
  }

  Future<void> _fetchPodcastData() async {
    try {
      await spotifyService.authenticate(); // Authenticate first

      // Fetch multiple podcasts; for example, you can call this method for each podcast you want to retrieve.
      List<String> podcastIds = [
        '0edOBjruWV6Juxf42WjGxw?si=8a9cacba93ef4f4b',
        // Add more podcast IDs here
        '46DjgGtGyyXWeesSZB5Btp?si=4164b02c565e4763',
      ];

      for (String id in podcastIds) {
        Map<String, dynamic>? podcastData = await spotifyService.getPodcastDetails(id);
        if (podcastData != null) {
          sleepingPodcasts.add(podcastData); // Add each podcast to the list
        }
      }

      print('Sleeping podcasts data: $sleepingPodcasts');
      setState(() {}); // Update the UI
    } catch (error) {
      print('Error fetching podcast data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.textFieldColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  child: Image.asset(
                    'assets/discover/sleep.jpg',
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
                      'Sleeping guide',
                      style: titleBlack.copyWith(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Description
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Relax and unwind with this guided sleep meditation.',
                        style: greySmallText.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'This meditation is designed to help you fall asleep faster and stay asleep longer. '
                            'It will help you relax your body and mind, and prepare you for a restful night of sleep.',
                        style: greySmallText.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'As you lay comfortably in your bed, close your eyes and take a deep breath in. '
                          'Exhale slowly and feel your body begin to relax. '
                          'Imagine a wave of relaxation flowing from the top of your head down to your toes. '
                          'Feel your muscles relax and your mind become calm. '
                          'Focus on the soothing music and let it guide you into a peaceful sleep. '
                          'Continue to breathe deeply and slowly, allowing yourself to drift deeper into relaxation.',
                      style: greySmallText.copyWith(fontSize: 14.0),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            // Additional content
            SizedBox(height: screenHeight * 0.025),
            Text(
              'Here are the podcast sessions to help you get started on breathing exercise: \n',
              style: greySmallText.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            ),
            // Display all podcasts
            ...sleepingPodcasts.map((podcast) {
              return PodcastCard(
                title: podcast['name'] ?? 'Untitled',
                description: podcast['description'] ?? 'No description available.',
                imageUrl: podcast['imageUrl'] ?? '',
                spotifyLink: podcast['externalUrl'] ?? '',
                youtubeLink: null,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
