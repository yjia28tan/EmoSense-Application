import 'package:emosense/design_widgets/app_color.dart';
import 'package:flutter/material.dart';

class Emotion {
  final String name;
  final String assetPath; // Path to the image asset
  final Color color;
  final Color containerColor;

  Emotion({
    required this.name,
    required this.assetPath,
    required this.color,
    required this.containerColor,
  });


  static List<Emotion> emotions = [
    Emotion(
        name: 'Happy',
        assetPath: 'assets/emotion/happy.png',
        color: AppColors.happy,
        containerColor: AppColors.happyContainer
    ),
    Emotion(name: 'Neutral',
        assetPath: 'assets/emotion/neutral.png',
        color: AppColors.neutral,
        containerColor: AppColors.neutralContainer
    ),
    Emotion(name: 'Fear',
        assetPath: 'assets/emotion/fear.png',
        color: AppColors.fear,
        containerColor: AppColors.fearContainer
    ),
    Emotion(name: 'Disgust',
        assetPath: 'assets/emotion/disgust.png',
        color: AppColors.disgust,
        containerColor: AppColors.disgustContainer
    ),
    Emotion(name: 'Angry',
        assetPath: 'assets/emotion/angry.png',
        color: AppColors.angry,
        containerColor: AppColors.angryContainer
    ),
    Emotion(name: 'Sad',
        assetPath: 'assets/emotion/sad.png',
        color: AppColors.sad,
        containerColor: AppColors.sadContainer
    ),
  ];
}

List<Emotion> emotions = [
  Emotion(
      name: 'Happy',
      assetPath: 'assets/emotion/happy.png',
      color: AppColors.happy,
      containerColor: AppColors.happyContainer
  ),
  Emotion(name: 'Neutral',
      assetPath: 'assets/emotion/neutral.png',
      color: AppColors.neutral,
      containerColor: AppColors.neutralContainer
  ),
  Emotion(name: 'Fear',
      assetPath: 'assets/emotion/fear.png',
      color: AppColors.fear,
      containerColor: AppColors.fearContainer
  ),
  Emotion(name: 'Disgust',
      assetPath: 'assets/emotion/disgust.png',
      color: AppColors.disgust,
      containerColor: AppColors.disgustContainer
  ),
  Emotion(name: 'Angry',
      assetPath: 'assets/emotion/angry.png',
      color: AppColors.angry,
      containerColor: AppColors.angryContainer
  ),
  Emotion(name: 'Sad',
      assetPath: 'assets/emotion/sad.png',
      color: AppColors.sad,
      containerColor: AppColors.sadContainer
  ),
];
