import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/meditation_tools_model.dart';
import 'package:emosense/pages/discover_breathing_page.dart';
import 'package:emosense/pages/discover_mindfulness_page.dart';
import 'package:flutter/material.dart';

class MeditationGuidePage extends StatelessWidget {
  final MeditationTool tool;

  const MeditationGuidePage({Key? key, required this.tool}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget guideContentWidget;

    // Determine which guide content widget to display based on the selected tool
    switch (tool.title) {
      case 'Mindfulness meditation':
        guideContentWidget = MindfulnessGuideContent();
        break;
      case 'Breathing exercise':
        guideContentWidget = BreathingGuideContent();
        break;
      case 'Sleeping guide':
        // guideContentWidget = SleepingGuideContent();
        guideContentWidget = Container();
        break;
      case 'Stress relief':
        // guideContentWidget = StressReliefGuideContent();
        guideContentWidget = Container();
        break;
      default:
        guideContentWidget = Container(); // Default empty widget
    }

    return Scaffold(
      backgroundColor: AppColors.textFieldColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textColorBlack),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.textFieldColor,
        title: Container(
          alignment: Alignment.center,
          child: Text( "Meditation Guide",
            style: titleBlack,
          ),
        ),
        actions: [
          Container(width: 48),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: guideContentWidget, // Display the selected guide content widget
      ),
    );
  }
}
