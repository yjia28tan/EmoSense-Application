import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/alert_dialog_widget.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/emotion_model.dart';
import 'package:emosense/design_widgets/emotion_trends_line_graphs.dart';
import 'package:emosense/design_widgets/stress_level_chart.dart';
import 'package:emosense/design_widgets/stress_model.dart';
import 'package:emosense/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/design_widgets/font_style.dart';

class WeeklyViewHome extends StatefulWidget {
  @override
  _WeeklyViewHomeState createState() => _WeeklyViewHomeState();
}

class _WeeklyViewHomeState extends State<WeeklyViewHome> {
  DateTime _selectedDate = DateTime.now();
  late String formattedDate;
  late String startFormatted;
  late String endFormatted;
  List<Map<String, dynamic>> _emotionForThisWeek = [];
  StressModel _currentStressLevel = stressModels.last;
  double? _currentStressLevelValue;
  int counter = 0;

  Map<String, int> stressCounts = {
    "Extreme": 0,
    "High": 0,
    "Optimal": 0,
    "Moderate": 0,
    "Low": 0,
  };


  @override
  void initState() {
    super.initState();
    setState(() {
      _resetToToday();
      _fetchDataForSelectedWeek(); // Fetch data on initialization
    });
  }

  Future<void> _fetchDataForSelectedWeek() async {
    try {
      final uid = globalUID;

      // Calculate the start and end of the selected week
      // Start from Monday at 00:00:00
      final startOfWeek = _selectedDate.subtract(
        Duration(days: _selectedDate.weekday - 1), // Move to Monday
      ).copyWith(hour: 0, minute: 0, second: 0);

      // End on Sunday at 23:59:59
      final endOfWeek = startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );

      // Fetch emotion records for the selected week
      final emotionSnapshot = await FirebaseFirestore.instance
          .collection('emotionRecords')
          .where('uid', isEqualTo: uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfWeek)
          .where('timestamp', isLessThanOrEqualTo: endOfWeek)
          .get();

      List<Map<String, dynamic>> emotions = [];

      if (emotionSnapshot.docs.isNotEmpty) {
        for (var doc in emotionSnapshot.docs) {
          emotions.add({
            'docId': doc.id,
            'emotion': doc['emotion'],
            'timestamp': doc['timestamp'],
            'stressLevel': doc['stressLevel'],
            'description': doc['description'],
          });
        }
      }
      // Calculate the average stress level and update the state
      _calculateAverageStressLevel(emotions);

      // Calculate stress level counts and update the counter
      stressCounts = _calculateStressLevelCounts(emotions);
      counter = emotions.length;

      // Update state with the emotions fetched for the week
      setState(() {
        _emotionForThisWeek = emotions;
      });
    } catch (error) {
      showAlert(context, 'Error', 'Error fetching weekly data: $error');
    }
  }

  void _calculateAverageStressLevel(List<Map<String, dynamic>> emotions) {
    if (emotions.isNotEmpty) {
      double totalStress = emotions.fold(0.0, (sum, emotion) {
        try {
          return sum + double.parse(emotion['stressLevel'] as String);
        } catch (e) {
          print('Error converting stress level to double: $e');
          return sum;
        }
      });

      _currentStressLevelValue = totalStress / emotions.length;
      print('Average Stress Level: $_currentStressLevelValue');

      _currentStressLevel = getStressLevel(_currentStressLevelValue!);
    } else {
      _currentStressLevel = stressModels.last;
    }
  }

  Map<String, int> _calculateStressLevelCounts(List<Map<String, dynamic>> emotions) {
    Map<String, int> stressCounts = {
      "Low": 0,
      "Moderate": 0,
      "Optimal": 0,
      "High": 0,
      "Extreme": 0,
    };

    emotions.forEach((emotion) {
      double stressLevelAsDouble = _parseStressLevel(emotion['stressLevel']);
      String stressLevel = getStressLevelAsString(stressLevelAsDouble);

      if (stressCounts.containsKey(stressLevel)) {
        stressCounts[stressLevel] = (stressCounts[stressLevel] ?? 0) + 1;
      }
    });
    return stressCounts;
  }

  double _parseStressLevel(dynamic stressLevelValue) {
    if (stressLevelValue is String) {
      return double.tryParse(stressLevelValue) ?? 2.0;
    } else if (stressLevelValue is double) {
      return stressLevelValue;
    } else {
      print('Warning: Unrecognized stress level type: ${stressLevelValue.runtimeType}');
      return 2.0; // Default if type unrecognized
    }
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

  void _resetToToday() {
    setState(() {
      _selectedDate = DateTime.now(); // Reset to today's date
      _updateFormattedDate(); // Update the date display based on the selected view
    });
  }

  void _updateFormattedDate() {
    formattedDate = _getWeeklyDateRange();
    startFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate.subtract(Duration(days: _selectedDate.weekday - 1)));
    endFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate.add(Duration(days: DateTime.daysPerWeek - _selectedDate.weekday)));
  }

  String _getWeeklyDateRange() {
    // Calculate the start and end of the selected week from Monday to Sunday
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final endOfWeek = _selectedDate.add(Duration(days: DateTime.daysPerWeek - _selectedDate.weekday));
    final startFormatted = DateFormat('d MMM').format(startOfWeek);
    final endFormatted = DateFormat('d MMM').format(endOfWeek);

    formattedDate = '$startFormatted - $endFormatted';
    return formattedDate;
  }

  void _showPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 7));
      _updateFormattedDate();
      _fetchDataForSelectedWeek(); // Refetch the data for the new week
    });
  }

  void _showNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 7));
      _updateFormattedDate();
      _fetchDataForSelectedWeek(); // Refetch the data for the new week
    });
  }

  bool _isThisWeek() {
    final now = DateTime.now();

    // Get the start and end of the current week (from Monday to Sunday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final endOfWeek = now.add(Duration(days: DateTime.daysPerWeek - now.weekday)); // Sunday

    // Check if the selected date is within the current week range
    return _selectedDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        _selectedDate.isBefore(endOfWeek.add(const Duration(seconds: 1)));
  }

  Color _getBarColorForEmotion(String emotion) {
    // Customize color based on the emotion
    switch (emotion) {
      case 'Happy':
        return AppColors.happy;
      case 'Sad':
        return AppColors.sad;
      case 'Neutral':
        return AppColors.neutral;
      case 'Angry':
        return AppColors.angry;
      case 'Fear':
        return AppColors.fear;
      case 'Disgust':
        return AppColors.disgust;
      default:
        return AppColors.lightLogoColor; // Default color if emotion doesn't match
    }
  }

  Widget _getEmotionIcon(String mood, double iconSize) {
    final emotion = Emotion.emotions.firstWhere(
          (e) => e.name == mood,
      orElse: () => Emotion(
        name: 'Unknown',
        assetPath: 'assets/logo.png',
        color: Colors.transparent,
        containerColor: Colors.transparent,
        valence: 0,
      ),
    );

    return Image.asset(
      emotion.assetPath,
      width: iconSize,  // Set the size dynamically
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Generate reflections and suggestions
    List<String> reflections = generateReflections(_emotionForThisWeek);

    print('to get suggestion Stress Level: $_currentStressLevelValue');
    List<String> stressSuggestion = _currentStressLevelValue != null
        ? generateSuggestions(_currentStressLevelValue!)
        : [];

    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Button to go to the previous day/week/month
              IconButton(
                iconSize: screenHeight * 0.02, // Adjusting icon size based on screen height
                icon: Icon(Icons.arrow_back_ios_outlined),
                onPressed: () {
                  _showPreviousWeek();
                },
              ),
              Text(
                formattedDate,
                style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
              ),
              IconButton(
                iconSize: screenHeight * 0.02,
                icon: Icon(Icons.arrow_forward_ios_outlined),
                onPressed: _isThisWeek() ? null : _showNextWeek, // Disable button if in current week
                color: _isThisWeek() ? AppColors.textFieldColor : null, // Grey out the icon if disabled
              ),

            ],
          ),
        ),

        // Display the emotion count chart
        _buildEmotionCountChart(context),

        // Display the stress level chart
        _buildStressLevelContainer(),

        // Display the emotion trends chart
        _buildEmotionTrendsChart(),

        // Reflections and Stress Suggestions
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 4, right: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Analysis & Reflections',
                    style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
                  ),
                ),
              ),
              if (counter == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'No reflections available for today.',
                    style: greySmallText.copyWith(fontSize: 14),
                  ),
                ),
              if (counter > 0) ...[
                // display the reflections
                ..._buildReflections(reflections),

                // Display the stress suggestions header
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Stress Relief Suggestions',
                    style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
                  ),
                ),
                // Display the stress relief suggestions
                ..._buildSuggestions(stressSuggestion),
              ],
            ],
          ),
        ),

        SizedBox(height: 25),
      ],
    );
  }

  List<Widget> _buildReflections(List<String> reflections) {
    return reflections.map((reflection) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          reflection,
          style: greySmallText.copyWith(
              fontSize: 14, fontStyle: FontStyle.normal),
          textAlign: TextAlign.justify,
        ),
      );
    }).toList();
  }

  List<Widget> _buildSuggestions(List<String> suggestions) {
    return suggestions.map((suggestion) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          suggestion,
          style: greySmallText.copyWith(fontSize: 14, fontStyle: FontStyle.normal),
          textAlign: TextAlign.justify,
        ),
      );
    }).toList();
  }

  List<String> generateReflections(List<Map<String, dynamic>> emotionData) {
    List<String> reflections = [];

    if (emotionData.isNotEmpty) {
      int positiveCount = emotionData.where((emotion) => emotion['emotion'] == 'Happy').length;
      int negativeCount = emotionData.where((emotion) => emotion['emotion'] == 'Sad').length;

      double averageValence = emotionData.map((e) => _getEmotionValence(e['emotion'])).reduce((a, b) => a + b) / emotionData.length;

      if (positiveCount > negativeCount) {
        reflections.add('You experienced more happiness emotion than sad emotion this week. \nKeep focusing on the positive moments!');
        reflections.add('Consider what made you happy and how you can replicate those moments.');
        reflections.add('Reflect on the positive aspects of your life.\n\n');
      } else if (negativeCount > positiveCount) {
        reflections.add('You had some sad moments this week. \nConsider what might have caused those feelings.');
        reflections.add('Reflect on ways to improve your mood and seek support if needed.');
        reflections.add('Remember that it is normal to experience a range of emotions.');
        reflections.add('Consider what can make you happy and how you can replicate those moments.\n\n');
      } else { // when happy == sad
        reflections.add('You experienced an equal number of happy and sad emotions this week. \n');
      }

      if (averageValence < 0) {
        reflections.add('Overall, the emotional trend indicates more negative emotions. \n');
        reflections.add('Consider what might have caused these feelings and how you can address them.');
        reflections.add('Reflect on ways to improve your mood and seek support if needed.');
        reflections.add('Remember that it is normal to experience a negative emotions, but it is important to address them.');
      } else if (averageValence > 0) {
        reflections.add('Overall, the emotional trend indicates more positive emotions. \n');
        reflections.add('Consider what made you happy and how you can replicate those moments.');
        reflections.add('Reflect on the positive aspects of your life and seek to maintain this positive trend.');
      } else {
        reflections.add('You experienced a mix of emotions this week. \n');
        reflections.add('Consider what might have caused the mix feelings and how you can address them.');
        reflections.add('Try to maintain a balance between positive and negative emotions.');
        reflections.add('Reflect on ways to improve your mood and seek support if needed.');
        reflections.add('Remember that it is normal to experience a range of emotions.');
      }
    }

    return reflections;
  }

  List<String> generateSuggestions(double averageStressLevel) {
    List<String> suggestions = [];

    if (averageStressLevel >= 3.0) {
      suggestions.add('Consider practicing mindfulness or meditation to reduce stress.');
      suggestions.add('Engage in physical activities to relieve tension.');
      suggestions.add('Seek support from friends or family to discuss your feelings.');
      suggestions.add('\nMore suggestions for stress relief can be found in the "Stress Relief" section of the Discover page.');

    } else if (averageStressLevel > 2.0 && averageStressLevel < 3.0) {
      suggestions.add('You have maintained an optimal stress level this week. Keep up the good work! ><');
      suggestions.add('Practice deep breathing exercises to relax your mind and body.');
      suggestions.add('Take regular breaks during your day to refresh your mind.');
      suggestions.add('Try journaling your thoughts and feelings.');
    } else if (averageStressLevel <= 2.0 && averageStressLevel > 0.0) {
      suggestions.add('WELL DONE! You are managing your stress well. Keep it up! ^^');
      suggestions.add('Spend time on hobbies or activities you enjoy.');
      suggestions.add('Practice gratitude by reflecting on positive aspects of your life.');
      suggestions.add('Connect with friends or family to share your positive experiences.');
    }else {
      suggestions.add('Maintain a healthy balance of work and leisure.');
    }

    return suggestions;
  }

  double _getEmotionValence(String emotion) {
    switch (emotion) {
      case 'Happy':
        return 5.0;
      case 'Neutral':
        return 0.0;
      case 'Sad':
        return -3.0;
      case 'Fear':
        return -4.0;
      case 'Angry':
        return -5.0;
      case 'Disgust':
        return -4.0;
      default:
        return 0.0;
    }
  }

  Widget _buildEmotionCountChart(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Define all possible emotions
    List<String> allEmotions = ["Angry", "Neutral", "Happy", "Disgust", "Sad", "Fear"];

    // Prepare data for the chart, including emotions with 0 occurrences
    Map<String, int> emotionData = {
      for (var emotion in allEmotions) emotion: 0
    };

    // Update the emotion counts from the fetched data
    for (var emotion in _emotionForThisWeek) {
      String emotionName = emotion['emotion'];
      emotionData[emotionName] = (emotionData[emotionName] ?? 0) + 1;
    }

    // Create a list of BarChartGroupData from the emotionData
    List<BarChartGroupData> barChartGroups = [];
    int index = 0;
    emotionData.forEach((emotion, count) {
      barChartGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: _getBarColorForEmotion(emotion), // Customize bar color based on the emotion
              borderRadius: BorderRadius.circular(15),
              width: 30, // Set a fixed width for bars
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 5, // Fixed height for the background bar for visual consistency
                color: Colors.transparent,
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
      index++;
    });

    // Return the bar chart widget
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 4, right: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Emotion Count',
                  style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
              ),
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false), // Remove the border around the chart
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // Remove Y-axis labels
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // No Y-axis labels
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // No Y-axis on the right
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          String emotion = allEmotions[value.toInt()]; // Get emotion based on value

                          return Column(
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              _getEmotionIcon(emotion, 45),
                              Text(
                                emotion, // Display the emotion name below the icon
                                style: TextStyle(
                                  color: AppColors.textColorBlack,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  ),
                  barGroups: barChartGroups,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBorder: BorderSide.none,
                      tooltipPadding: EdgeInsets.only(bottom: 2), // Remove any padding
                      tooltipMargin: 0, // Remove the margin
                      // Customize the tooltip appearance
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()}', // Show the emotion count on top of the bar
                          greySmallText.copyWith(
                            fontSize: 12,
                            color: AppColors.textColorBlack,
                            backgroundColor: Colors.transparent, // Remove background color
                          ),
                        );
                      },
                      getTooltipColor: (group) {
                        return Colors.transparent;
                      },

                    ),
                  ),

                  gridData: FlGridData(show: false), // Disable grid lines
                  alignment: BarChartAlignment.spaceAround, // Space the bars evenly
                  maxY: 12, // Maximum Y value (assuming 5 for visual consistency)
                ),
              ),
            ),
            SizedBox(height: 10),

          ],
        ),
      ),
    );
  }

  Widget _buildStressLevelContainer() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5, left: 4, right: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Stress Level',
                          style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
                        ),
                      ),
                    ),
                    // Add the half pie chart for stress levels here if needed
                    if (counter == 0)
                      SizedBox(
                        height: 110,
                        width: 150,
                      ),
                    if (counter > 0)
                      SizedBox(
                        height: 110,
                        width: 150,
                        child: HalfDonutChart(stressCounts: stressCounts),
                      ),

                    // Display the current stress level that was calculated
                    Center(
                      child: Container(
                        height: 32,
                        width: screenWidth * 0.25,
                        decoration: BoxDecoration(
                          color: counter == 0 ? AppColors.textFieldColor : _currentStressLevel.containerColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            counter == 0 ? "None" : _currentStressLevel.level, // Show the current stress level
                            style: titleBlack.copyWith(fontSize: 14),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Tooltip(
              message: "This chart shows the distribution of stress levels throughout the week.\n"
                  "Color Indicator: \nRed - Extreme, \nOrange - High, \nYellow - Optimal, \nGreen - Moderate, \nBlue - Low.\n\n"
                  "The stress level displayed below is the average stress throughout the week.",
              padding: EdgeInsets.all(8.0),  // Control the padding inside the tooltip box
              verticalOffset: 15,  // Adjust how far the tooltip is from the target widget
              preferBelow: false,  // Show the tooltip above the widget
              margin: EdgeInsets.only(left: 85, right: 10),  // Adjust the margin between the tooltip and the widget
              textStyle: TextStyle(
                fontSize: 14.0,  // Set the text size
                color: Colors.white,
              ),
              decoration: BoxDecoration(
                color: AppColors.textColorGrey,  // Background color of the tooltip
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline,
                color: AppColors.textColorGrey,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionTrendsChart() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Stack(
        children: [

        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 4, right: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Emotional Trends',
                    style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
                  ),
                ),
              ),
              // Calculate the average stress level for the week and display the graph
              if (counter == 0)
                SizedBox(
                  height: 110,
                  width: 150,
                ),
              if (counter > 0)
                SizedBox(
                  width: double.infinity,
                  child: EmotionTrendLineChart(emotionData: _emotionForThisWeek),
                ),
            ],
          ),
        ),
          Positioned(
            top: 5,
            right: 5,
            child: Tooltip(
              message: "This chart displays fluctuations in emotional valence over time,"
                  "with the X-axis representing timestamps and "
                  "the Y-axis quantifying emotions from -5 (negative) to 5 (positive).\n"
                  "\nThis visualization helps users reflect on their emotional well-being "
                  "and identify patterns in their feelings.",
              padding: EdgeInsets.all(8.0),  // Control the padding inside the tooltip box
              verticalOffset: 15,  // Adjust how far the tooltip is from the target widget
              preferBelow: false,  // Show the tooltip above the widget
              margin: EdgeInsets.only(left: 85, right: 10),  // Adjust the margin between the tooltip and the widget
              textStyle: TextStyle(
                fontSize: 14.0,  // Set the text size
                color: Colors.white,
              ),
              decoration: BoxDecoration(
                color: AppColors.textColorGrey,  // Background color of the tooltip
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline,
                color: AppColors.textColorGrey,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

}