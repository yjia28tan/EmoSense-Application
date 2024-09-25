import 'package:emosense/design_widgets/app_color.dart';
import 'package:flutter/material.dart';

class Emotion {
  final String name;
  final String assetPath; // Path to the image asset
  final Color color;

  Emotion({
    required this.name,
    required this.assetPath,
    required this.color,
  });
}

List<Emotion> emotions = [
  Emotion(name: 'Happy', assetPath: 'assets/emotion/happy.png', color: AppColors.happy),
  Emotion(name: 'Neutral', assetPath: 'assets/emotion/neutral.png', color: AppColors.neutral),
  Emotion(name: 'Fear', assetPath: 'assets/emotion/fear.png', color: AppColors.fear),
  Emotion(name: 'Disgust', assetPath: 'assets/emotion/disgust.png', color: AppColors.disgust),
  Emotion(name: 'Angry', assetPath: 'assets/emotion/angry.png', color: AppColors.angry),
  Emotion(name: 'Sad', assetPath: 'assets/emotion/sad.png', color: AppColors.sad),
];
