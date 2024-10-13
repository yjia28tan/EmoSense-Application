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
  // final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void dispose() {
    // flutterTts.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  // Future<void> _speakInstructions() async {
  //   await flutterTts.speak(
  //     // Insert the breathing exercise instructions here
  //     'Three Steps to Deep Breathing\n\n'
  //         'In order to experience deep breathing,\n first\n you will have to identify\n and experience\n the three types of breathing that comprise it.\n For this exercise\n it is better to lay down on your back if possible.\n Place the right hand\n on top of your navel\n and the left hand\n on top of your chest.\n\n Start by observing the natural flow of your breath for a few cycles.\n\n'
  //         '\n\nAbdominal breathing.\n\n'
  //         'With the next inhalation,\n think of intentionally sending the air\n towards the navel\n by letting your abdomen expand and rise freely.\n\n'
  //         'Feel the right hand rising while the left hand remains almost still on top of the chest.\n\n'
  //         'Feel the right hand coming down as you exhale while keeping the abdomen relaxed.\n\n'
  //         'Continue to repeat this for a few minutes without straining the abdomen,\n but rather allowing it to expand and relax freely.\n\n'
  //         'After some repetitions,\n return to your natural breathing.\n\n'
  //         '\n\nThoracic breathing.\n\n'
  //         'Without changing your position,\n you will now shift your attention to your ribcage.\n\n'
  //         'With the next inhalation,\n think of intentionally sending the air\n towards your rib cage\n instead of the abdomen.\n\n'
  //         'Let the thorax expand\n and rise freely,\n allowing your left hand\n to move up\n and down\n as you keep breathing.\n\n'
  //         'Breath through the chest\n without engaging your diaphragm,\n slowly\n and deeply.\n\n'
  //         'Your right hand\n should remain almost still.\n\n'
  //         'Continue to repeat this breathing pattern for a few minutes.\n\n'
  //         'After some repetitions,\n return to your natural breathing.\n\n'
  //         '\n\nClavicular breathing.\n\n'
  //         'With the next inhalation,\n repeat the thoracic breathing pattern.\n\n'
  //         'When the ribcage is completely expanded,\n inhale a bit more thinking\n of allowing the air\n to fill the upper section of your lungs\n at the base of your neck.\n\n'
  //         'Feel the shoulders\n and collar bone\n rise up gently\n to find some space for the extra air to come in.\n\n'
  //         'Exhale slowly\n letting the collarbone\n and shoulders\n drop first\n and then\n continue to relax the ribcage.\n\n'
  //         'Continue to repeat this for a few minutes.\n\n'
  //         'After some repetitions,\n return to your natural breathing.',
  //   );
  // }

  // Future<void> _playSound() async {
  //   await audioPlayer.play(AssetSource('audio/deepMeditation.mp3'), volume: 1); // Adjust the volume as needed
  // }
  //
  // Future<void> _stopSound() async {
  //   await audioPlayer.stop();
  // }
  //
  // Future<void> _playInstructionsWithMusic() async {
  //   // Play the background music
  //   await _playSound();
  //   // Speak the instructions
  //   await _speakInstructions();
  //   // Stop the music after speaking
  //   await _stopSound();
  // }

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
                Positioned(
                  right: 16.0,
                  bottom: 16.0,
                  child: GestureDetector(
                    onTap: () async {
                      // if (isPlaying) {
                      //   await flutterTts.stop();
                      //   await _stopSound();
                      // } else {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       content: Text('Playing Instructions...'),
                      //       duration: Duration(seconds: 2),
                      //     ),
                      //   );
                      //   await _playSound();
                      //   await _playInstructionsWithMusic();
                      // }
                      // setState(() {
                      //   isPlaying = !isPlaying;
                      // });
                    },
                    child: CircleAvatar(
                      radius: 24.0,
                      backgroundColor: AppColors.upBackgroundColor,
                      child: Icon(
                        isPlaying ? Icons.stop : Icons.play_arrow,
                        color: AppColors.darkPurpleColor,
                        size: 32.0,
                      ),
                    ),
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
                  SizedBox(height: 4.0),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '5 mins',
                      style: greySmallText.copyWith(fontSize: 14.0),
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
              'Here are the podcast sessions to help you get started: \n',
              style: greySmallText.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            ),
            // if (mindfulness_podcastData != null) // Check if podcast data is available
            //   PodcastCard(
            //     title: 'Mindful Meditations by Mindful.org',
            //     description: mindfulness_podcastData!['description'],
            //     imageUrl: mindfulness_podcastData!['imageUrl'],
            //     spotifyLink: mindfulness_podcastData!['externalUrl'],
            //     youtubeLink: 'https://www.youtube.com/channel/UCXsjej0djMYxtGC3RMHBUvg',
            //   ),
          ],
        ),
      ),
    );
  }
}
