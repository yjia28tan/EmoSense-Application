// stress_model.dart
import 'package:emosense/design_widgets/app_color.dart';
import 'package:flutter/material.dart';

class StressModel {
  final String level;
  final Color color;
  final Color containerColor;
  final String description;
  final String description2;
  final String assetPath;

  StressModel({
    required this.level,
    required this.color,
    required this.containerColor,
    required this.description,
    required this.description2,
    required this.assetPath,
  });
}

final List<StressModel> stressModels = [
  StressModel(
    level: "Extreme", // 4.0
    color: AppColors.stress_low,
    containerColor: AppColors.angryContainer,
    description: "Exhaustion, anxiety, burnout",
    description2: "\"I can't take this anymore\"",
    assetPath: 'assets/stress/extreme.png',
  ),
  StressModel(
    level: "High", // 3.0
    color: AppColors.stress_moderate,
    containerColor: AppColors.neutralContainer,
    description: "Distracted, fatigue, overwhelm",
    description2: "\"I feel anxious & unfocused\"",
    assetPath: 'assets/stress/high.png',
  ),
  StressModel(
    level: "Optimal", // 2.0
    color: AppColors.stress_optimal,
    containerColor: AppColors.happyContainer,
    description: "Confident, in control, productive",
    description2: "\"I'm really in the zone\"",
    assetPath: 'assets/stress/optimal.png',
  ),
  StressModel(
    level: "Moderate", // 1.0
    color: AppColors.stress_high,
    containerColor: AppColors.disgustContainer,
    description: "Engaged, focused, motivated",
    description2: "\"I feel focused & energized\"",
    assetPath: 'assets/stress/moderate.png',
  ),
  StressModel(
    level: "Low", // 0.0
    color: AppColors.stress_extreme,
    containerColor: AppColors.sadContainer,
    description: "Inactive, bored, unchallenged",
    description2: "\"I wish I had more to do\"",
    assetPath: 'assets/stress/low.png',
  ),
];

// Method to get the stress level based on the average stress level
StressModel getStressLevel(double averageStressLevel) {
  if (averageStressLevel >= 3.5) {
    return stressModels.firstWhere((model) => model.level == "Extreme");
  } else if (averageStressLevel >= 2.5) {
    return stressModels.firstWhere((model) => model.level == "High");
  } else if (averageStressLevel >= 1.5) {
    return stressModels.firstWhere((model) => model.level == "Optimal");
  } else if (averageStressLevel >= 0.5) {
    return stressModels.firstWhere((model) => model.level == "Moderate");
  } else {
    return stressModels.firstWhere((model) => model.level == "Low");
  }
}
