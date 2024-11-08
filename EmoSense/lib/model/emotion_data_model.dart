import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/model/emotion_model.dart';
import 'package:emosense/model/stress_model.dart';

class EmotionData {
  final String docId; // Add docId field
  final Emotion emotion;
  final StressModel stressLevel;
  final String description;
  final DateTime timestamp;

  EmotionData({
    required this.docId, // Include docId in the constructor
    required this.emotion,
    required this.stressLevel,
    required this.description,
    required this.timestamp,
  });

  factory EmotionData.fromMap(Map<String, dynamic> map, String documentId) {
    // Handle null values for emotion and description
    String emotionName = map['emotion'] as String? ?? '';
    String description = map['description'] as String? ?? '';

    // Retrieve the stress level as a double, handle nulls
    double stressLevelValue = (map['stressLevel'] is double)
        ? map['stressLevel'] as double
        : double.tryParse(map['stressLevel']?.toString() ?? '') ?? 2.0; // Default to 2.0 if null

    // Find the corresponding StressModel using the double value
    StressModel stressModel;
    try {
      stressModel = stressModels.firstWhere(
            (s) => s.level == getStressLevelAsString(stressLevelValue),
        orElse: () => stressModels.last, // Fallback to the last stress model if no match found
      );
    } catch (e) {
      stressModel = stressModels.last; // Fallback in case of an exception
    }

    // Ensure timestamp is correctly parsed
    DateTime timestamp;
    if (map['timestamp'] is Timestamp) {
      timestamp = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      timestamp = DateTime.tryParse(map['timestamp']) ?? DateTime.now(); // Fallback to current time
    } else {
      timestamp = DateTime.now(); // Fallback to current time if not available
    }

    return EmotionData(
      docId: documentId, // Assign the document ID
      emotion: Emotion.emotions.firstWhere(
            (e) => e.name == emotionName,
        orElse: () => Emotion.emotions.first, // Fallback to first emotion if not found
      ),
      stressLevel: stressModel,
      description: description,
      timestamp: timestamp,
    );
  }

  static String getStressLevelAsString(double level) {
    switch (level) {
      case 4.0:
        return "Extreme";
      case 3.0:
        return "High";
      case 2.0:
        return "Optimal";
      case 1.0:
        return "Moderate";
      case 0.0:
        return "Low";
      default:
        return "Unknown"; // Handle cases that don't match
    }
  }
}
