import 'package:audioplayers/audioplayers.dart';
import 'package:emosense/api_services/spotify_services.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/podcast_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BreathingGuideContent extends StatefulWidget {
  @override
  State<BreathingGuideContent > createState() => _BreathingGuideContentState();
}

class _BreathingGuideContentState extends State<BreathingGuideContent > {
  final SpotifyService spotifyService = SpotifyService();
  Map<String, dynamic>? breathing_podcastData;

  @override
  void initState() {
    super.initState();
    _fetchPodcastData();
  }

  Future<void> _fetchPodcastData() async {
    try {
      await spotifyService.authenticate(); // Authenticate first
      breathing_podcastData = await spotifyService.getPodcastDetails('7tPtOD4FvVPvWKRentMzVd?si=0a09fc09835e4f88');

      print('Breathing podcast data: $breathing_podcastData');
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
                    'assets/discover/breathing.jpg',
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
                      'Breathing exercises',
                      style: titleBlack.copyWith(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Description
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Three Steps to Deep Breathing',
                        style: greySmallText.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'In order to experience deep breathing, first you will have to identify and experience the three types of breathing that comprise it. '
                          'For this exercise it is better to lay down on your back if possible. '
                          'Place the right hand on top of your navel and the left hand on top of your chest. '
                          'Start by observing the natural flow of your breath for a few cycles.',
                      style: greySmallText.copyWith(fontSize: 14.0),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Abdominal breathing",
                      style: greySmallText.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'With the next inhalation, think of intentionally sending the air towards the navel by letting your abdomen expand and rise freely. '
                        'Feel the right hand rising while the left hand remains almost still on top of the chest. '
                        'Feel the right hand coming down as you exhale while keeping the abdomen relaxed. '
                        'Continue to repeat this for a few minutes without straining the abdomen, but rather allowing it to expand and relax freely. '
                        'After some repetitions, return to your natural breathing.',
                    style: greySmallText.copyWith(fontSize: 14.0),
                    textAlign: TextAlign.justify,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Thoracic Breathing",
                      style: greySmallText.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'Without changing your position, you will now shift your attention to your ribcage. '
                        'With the next inhalation, think of intentionally sending the air towards your rib cage instead of the abdomen. '
                        'Let the thorax expand and rise freely, allowing your left hand to move up and down as you keep breathing. '
                        'Breathe through the chest without engaging your diaphragm, slowly and deeply. Your right hand should remain almost still. '
                        'Continue to repeat this breathing pattern for a few minutes. After some repetitions, return to your natural breathing.',
                    style: greySmallText.copyWith(fontSize: 14.0),
                    textAlign: TextAlign.justify,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Clavicular Breathing",
                      style: greySmallText.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'With the next inhalation, repeat the thoracic breathing pattern. '
                        'When the ribcage is completely expanded, inhale a bit more thinking of allowing the air to fill the upper section of your lungs at the base of your neck.'
                        'Feel the shoulders and collar bone rise up gently to find some space for the extra air to come in. '
                        'Exhale slowly letting the collarbone and shoulders drop first and then continue to relax the ribcage. '
                        'Continue to repeat this for a few minutes. After some repetitions, return to your natural breathing.',
                    style: greySmallText.copyWith(fontSize: 14.0),
                    textAlign: TextAlign.justify,
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
            if (breathing_podcastData != null) // Check if podcast data is available
              PodcastCard(
                title: 'Mindful Breathing Exercise',
                description: breathing_podcastData!['description'],
                imageUrl: breathing_podcastData!['imageUrl'],
                spotifyLink: breathing_podcastData!['externalUrl'],
              ),
          ],
        ),
      ),
    );
  }
}
