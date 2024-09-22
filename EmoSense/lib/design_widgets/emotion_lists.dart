import 'package:emosense/design_widgets/app_color.dart';
import 'package:flutter/material.dart';

class Emotion {
  final String name;
  final IconData icon;
  final Color color;

  Emotion({
    required this.name,
    required this.icon,
    required this.color,
  });
}


List<Emotion> emotions = [
  Emotion(name: 'Happy', icon: Icons.sentiment_very_satisfied, color: AppColors.happy),
  Emotion(name: 'Neutral', icon: Icons.sentiment_satisfied, color: AppColors.neutral),
  Emotion(name: 'Fear', icon: Icons.sentiment_neutral, color: AppColors.fear),
  Emotion(name: 'Disgust', icon: Icons.sentiment_dissatisfied, color: AppColors.disgust),
  Emotion(name: 'Angry', icon: Icons.sentiment_very_dissatisfied, color: AppColors.angry),
  Emotion(name: 'Sad', icon: Icons.sentiment_very_dissatisfied, color: AppColors.sad),
];
