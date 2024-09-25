// stress_model.dart
import 'package:emosense/design_widgets/app_color.dart';
import 'package:flutter/material.dart';

class StressModel {
  final String level;
  final Color color;
  final String description;
  final String description2;
  final String assetPath;

  StressModel({
    required this.level,
    required this.color,
    required this.description,
    required this.description2,
    required this.assetPath,
  });
}

final List<StressModel> stressModels = [
  StressModel(
    level: "Extreme",
    color: AppColors.stress_low,
    description: "Exhaustion, anxiety, burnout",
    description2: "\"I can't take this anymore\"",
    assetPath: 'assets/stress/extreme.png',
  ),
  StressModel(
    level: "High",
    color: AppColors.stress_moderate,
    description: "Distracted, fatigue, overwhelm",
    description2: "\"I feel anxious & unfocused\"",
    assetPath: 'assets/stress/high.png',
  ),
  StressModel(
    level: "Optimal",
    color: AppColors.stress_optimal,
    description: "Confident, in control, productive",
    description2: "\"I'm really in the zone\"",
    assetPath: 'assets/stress/optimal.png',
  ),
  StressModel(
    level: "Moderate",
    color: AppColors.stress_high,
    description: "Engaged, focused, motivated",
    description2: "\"I feel focused & energized\"",
    assetPath: 'assets/stress/moderate.png',
  ),
  StressModel(
    level: "Low",
    color: AppColors.stress_extreme,
    description: "Inactive, bored, unchallenged",
    description2: "\"I wish I had more to do\"",
    assetPath: 'assets/stress/low.png',
  ),
];
