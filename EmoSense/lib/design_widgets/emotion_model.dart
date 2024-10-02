import 'package:emosense/design_widgets/app_color.dart';
import 'package:flutter/material.dart';

class Emotion {
  final String name;
  final String assetPath; // Path to the image asset
  final Color color;
  final Color containerColor;
  final int valence;

  Emotion({
    required this.name,
    required this.assetPath,
    required this.color,
    required this.containerColor,
    required this.valence,
  });


  static List<Emotion> emotions = [
    Emotion(
        name: 'Happy',
        assetPath: 'assets/emotion/happy.png',
        color: AppColors.happy,
        containerColor: AppColors.happyContainer,
        valence: 5
    ),
    Emotion(name: 'Neutral',
        assetPath: 'assets/emotion/neutral.png',
        color: AppColors.neutral,
        containerColor: AppColors.neutralContainer,
        valence: 0
    ),
    Emotion(name: 'Fear',
        assetPath: 'assets/emotion/fear.png',
        color: AppColors.fear,
        containerColor: AppColors.fearContainer,
        valence: -4
    ),
    Emotion(name: 'Disgust',
        assetPath: 'assets/emotion/disgust.png',
        color: AppColors.disgust,
        containerColor: AppColors.disgustContainer,
        valence: -4
    ),
    Emotion(name: 'Angry',
        assetPath: 'assets/emotion/angry.png',
        color: AppColors.angry,
        containerColor: AppColors.angryContainer,
        valence: -5
    ),
    Emotion(name: 'Sad',
        assetPath: 'assets/emotion/sad.png',
        color: AppColors.sad,
        containerColor: AppColors.sadContainer,
        valence: -3
    ),
  ];
}

List<Emotion> emotions = [
  Emotion(
      name: 'Happy',
      assetPath: 'assets/emotion/happy.png',
      color: AppColors.happy,
      containerColor: AppColors.happyContainer,
      valence: 5
  ),
  Emotion(name: 'Neutral',
      assetPath: 'assets/emotion/neutral.png',
      color: AppColors.neutral,
      containerColor: AppColors.neutralContainer,
      valence: 0
  ),
  Emotion(name: 'Fear',
      assetPath: 'assets/emotion/fear.png',
      color: AppColors.fear,
      containerColor: AppColors.fearContainer,
      valence: -4
  ),
  Emotion(name: 'Disgust',
      assetPath: 'assets/emotion/disgust.png',
      color: AppColors.disgust,
      containerColor: AppColors.disgustContainer,
      valence: -4
  ),
  Emotion(name: 'Angry',
      assetPath: 'assets/emotion/angry.png',
      color: AppColors.angry,
      containerColor: AppColors.angryContainer,
      valence: -5
  ),
  Emotion(name: 'Sad',
      assetPath: 'assets/emotion/sad.png',
      color: AppColors.sad,
      containerColor: AppColors.sadContainer,
      valence: -3
  ),
];
