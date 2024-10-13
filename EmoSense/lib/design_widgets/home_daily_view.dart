import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/alert_dialog_widget.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/emotion_model.dart';
import 'package:emosense/design_widgets/stress_level_chart.dart';
import 'package:emosense/design_widgets/stress_model.dart';
import 'package:emosense/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/design_widgets/font_style.dart';

class DailyViewHome extends StatefulWidget {
  @override
  _DailyViewHomeState createState() => _DailyViewHomeState();
}

class _DailyViewHomeState extends State<DailyViewHome> {
  DateTime _selectedDate = DateTime.now();
  late String formattedDate;
  List<Map<String, dynamic>> _emotionForToday = [];
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
    _resetToToday();
    setState(() {
      _fetchDataForSelectedDate(); // Fetch data on initialization
    });
  }

  Future<void> _fetchDataForSelectedDate() async {
    try {
      final uid = globalUID;

      DateTime dateTime = DateFormat('E, d MMM, yyyy').parse(formattedDate);
      final startOfDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final endOfDay = startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

      final emotionSnapshot = await FirebaseFirestore.instance
          .collection('emotionRecords')
          .where('uid', isEqualTo: uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .get();

      List<Map<String, dynamic>> emotions = emotionSnapshot.docs.map((doc) {
        return {
          'docId': doc.id,
          'emotion': doc['emotion'],
          'timestamp': doc['timestamp'],
          'stressLevel': doc['stressLevel'],
          'description': doc['description'],
        };
      }).toList();

      // Calculate the average stress level and update the state
      _calculateAverageStressLevel(emotions);

      // Calculate stress level counts and update the counter
      stressCounts = _calculateStressLevelCounts(emotions);
      counter = emotions.length;

      setState(() {
        _emotionForToday = emotions;
      });
    } catch (error) {
      showAlert(context, 'Error', 'Error fetching data: $error');
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

    print('Stress Counts: $stressCounts');
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

  void _resetToToday() {
    setState(() {
      _selectedDate = DateTime.now(); // Reset to today's date
      _updateFormattedDate(); // Update the date display based on the selected view
      _fetchDataForSelectedDate(); // Fetch the data for today
    });
  }

  void _updateFormattedDate() {
    formattedDate = DateFormat('E, d MMM, yyyy').format(_selectedDate);
  }

  void _showPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 1));
      _updateFormattedDate();
      _fetchDataForSelectedDate(); // Fetch data for the new date
    });
  }

  void _showNextDay() {
    if (!_isToday()) {
      setState(() {
        _selectedDate = _selectedDate.add(Duration(days: 1));
        _updateFormattedDate();
        _fetchDataForSelectedDate(); // Fetch data for the new date
      });
    }
  }

  bool _isToday() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Get the latest emotion for display
    Map<String, dynamic>? latestEmotion;
    if (_emotionForToday.isNotEmpty) {
      latestEmotion = _emotionForToday.last;
    }

    print('Latest Emotion: $latestEmotion');
    print('Average Stress Level: $_currentStressLevelValue');

    // Safely access the 'emotion' field, providing a default value if null
    String currentEmotion = latestEmotion?['emotion'] ?? 'NONE';

    print('Latest Emotion: $currentEmotion');

    // Use currentEmotion for your reflections
    List<String> reflections = _getReflectionQuestions(currentEmotion);

    // Check if _averageStressLevel is null before accessing it
    List<String> stressSuggestion = _currentStressLevelValue != null
        ? _getSuggestions(_currentStressLevelValue!)
        : []; // Provide an empty list or handle the null case

    print("Reflections: $reflections");
    print("Stress Suggestions: $stressSuggestion");


    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                iconSize: screenHeight * 0.02,
                icon: Icon(Icons.arrow_back_ios_outlined),
                onPressed: _showPreviousDay,
              ),
              Text(
                formattedDate,
                style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
              ),
              IconButton(
                iconSize: screenHeight * 0.02,
                icon: Icon(Icons.arrow_forward_ios_outlined),
                onPressed: _showNextDay,
                color: _isToday() ? AppColors.textFieldColor : null,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Today's Emotion
                _buildEmotionContainer(
                    latestEmotion != null ? _getEmotionIcon(latestEmotion['emotion'], screenHeight * 0.4)
                        : _getDefaultIcon(screenHeight * 0.08)),
                // Stress Level
                _buildStressLevelContainer(),
              ],
            ),
          ),
        ),
        _buildEmotionCountChart(context),

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
                      'Reflections',
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
                  // Display reflections
                  for (var reflection in reflections)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        reflection,
                        style: greySmallText.copyWith(fontSize: 14),
                      ),
                    ),

                  // Display the stress suggestions header
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Stress Relief Suggestions',
                      style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
                    ),
                  ),

                  // Display stress suggestions
                  for (var suggestion in stressSuggestion)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        suggestion,
                        style: greySmallText.copyWith(fontSize: 14),
                      ),
                    ),
                ],
              ],
        ),
        ),
        SizedBox(height: 25),
      ],
    );
  }

  Widget _buildEmotionContainer(Widget icon) {
    return Container(
      height: 185,
      width: 157,
      padding: EdgeInsets.all(10),
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
            padding: const EdgeInsets.only(left: 4, right: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Today\'s Emotion',
                style: titleBlack.copyWith(fontSize: 14),
              ),
            ),
          ),
          Center(child: icon), // Display the latest emotion icon and resize the icon to 180
        ],
      ),
    );
  }

  Widget _buildStressLevelContainer() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Container(
        height: 185,
        width: 158,
        padding: EdgeInsets.all(8),
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
                  style: titleBlack.copyWith(fontSize: 14),
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
        Positioned(
          top: 5,
          right: 5,
          child: Tooltip(
            message: "This chart shows the distribution of stress levels throughout the day.\n"
                "Color Indicator: \nRed - Extreme, \nOrange - High, \nYellow - Optimal, \nGreen - Moderate, \nBlue - Low.\n\n"
                "The stress level displayed below is the average stress throughout the day.",
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
    );
  }

  Widget _buildEmotionCountChart(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define all possible emotions
    List<String> allEmotions = ["Angry", "Neutral", "Happy", "Disgust", "Sad", "Fear"];

    // Prepare data for the chart, including emotions with 0 occurrences
    Map<String, int> emotionData = {
      for (var emotion in allEmotions) emotion: 0
    };

    // Update the emotion counts from the fetched data
    for (var emotion in _emotionForToday) {
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
                      tooltipPadding: EdgeInsets.all(5), // Remove any padding
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
                  maxY: 5, // Maximum Y value (assuming 5 for visual consistency)
                ),
              ),
            ),
            SizedBox(height: 10),

          ],
        ),
      ),
    );
  }

  Widget _getDefaultIcon(double iconSize) {
    return Image.asset(
      'assets/logo.png',
      width: 120,
    );
  }

  List<String> _getReflectionQuestions(String emotion) {
    switch (emotion) {
      case 'Happy':
        return [
          'What specific events contributed to your happiness today?',
          'How can you maintain or increase this positive feeling in the future?'
        ];
      case 'Sad':
        return [
          'What triggered your feelings of sadness today?',
          'What strategies can you use to cope with these feelings in the future?'
        ];
      case 'Angry':
        return [
          'What situations or events caused your anger today?',
          'What steps can you take to manage your anger more effectively in the future?'
        ];
      case 'Fear':
        return [
          'What were the specific fears you experienced today?',
          'How can you confront or mitigate these fears moving forward?'
        ];
      case 'Disgust':
        return [
          'What experiences or thoughts made you feel disgusted today?',
          'How can you reduce or avoid such triggers in the future?'
        ];
      case 'Neutral':
        return [
          'What activities did you engage in that left you feeling neutral?',
          'How can you introduce more stimulating activities to your routine?'
        ];
      default:
        return [];
    }
  }

  List<String> _getSuggestions(double stressLevel) {
    List<String> suggestions = [];

    if (stressLevel >= 3.0) {
      return [
        'Practice deep breathing exercises for 5-10 minutes.',
        'Engage in physical activity, such as a short walk or stretching.'
      ];
    } else if (stressLevel == 2.0) {
      return [
        'Take a short break to clear your mind. Consider mindfulness or meditation.',
        'Journal your thoughts to process your feelings.'
      ];
    } else if (stressLevel < 2.0 && stressLevel > 0.0) {
      return [
        'Spend time on hobbies or activities you enjoy.',
        'Connect with friends or family to share your positive experiences.'
      ];
    } else if (stressLevel == 0.0) {
      return [
        'Reflect on the positive aspects of your day.',
        'Plan activities for tomorrow that you look forward to.'
      ];
    } else {
      return suggestions; // Return an empty list if no conditions match
    }
  }


}

