import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/emotion_model.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/emotion_display_box.dart';
import 'package:emosense/main.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  String? _selectedEmotion;
  Map<DateTime, String> _emotionMap = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedDay = DateTime.now();
      _fetchDataForSelectedDay();
      _fetchAllEmotions();
    });
  }

  Future<void> _fetchDataForSelectedDay() async {
    final uid = globalUID;
    final startOfDay =
    DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final emotionSnapshot = await FirebaseFirestore.instance
        .collection('emotionRecords')
        .where('uid', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .limit(1)
        .get();

    String? emotion;
    if (emotionSnapshot.docs.isNotEmpty) {
      emotion = emotionSnapshot.docs.first['emotion'];
    }

    setState(() {
      _selectedEmotion = emotion;
    });
  }

  Future<void> _fetchAllEmotions() async {
    try {
      final uid = globalUID;

      // Fetch all emotion records for the user, ordered by timestamp descending
      final emotionSnapshot = await FirebaseFirestore.instance
          .collection('emotionRecord')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .get();

      print('Emotion snapshot: $emotionSnapshot');

      // Check if any data was fetched
      if (emotionSnapshot.docs.isEmpty) {
        print('No emotion data found for the user.');
      }

      Map<DateTime, String> emotionMap = {};

      // Iterate through the fetched records and keep only the latest for each day
      for (var doc in emotionSnapshot.docs) {
        DateTime date = (doc['timestamp'] as Timestamp).toDate();
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);

        // Debugging output to check which emotions are being processed
        print('Processing emotion: ${doc['emotion']} on date: $normalizedDate');

        // If the date is not yet in the map, add the emotion
        if (!emotionMap.containsKey(normalizedDate)) {
          emotionMap[normalizedDate] = doc['emotion'];
          print('Added emotion for $normalizedDate: ${doc['emotion']}');
        }
      }

      // Update the state with the filtered emotion map
      setState(() {
        _emotionMap = emotionMap;
        print('Emotion map updated: $_emotionMap');
      });
    } catch (error) {
      // Log any error that occurs during fetching
      print('Error fetching emotions: $error');
    }
  }


  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
    _fetchDataForSelectedDay();
  }

  /// This function now fetches the icon from the Emotion model based on the mood
  Widget _getEmotionIcon(String mood) {
    // Use the Emotion model to find the matching icon and color
    final emotion = Emotion.emotions.firstWhere(
            (e) => e.name == mood,
        orElse: () => Emotion(
            name: 'Unknown',
            assetPath: 'assets/logo.png',
            color: Colors.transparent,
            containerColor: Colors.transparent,
        )
    );

    if (emotion.assetPath.isNotEmpty) {
      return Image.asset(
        emotion.assetPath,
        width: 25,
        height: 25,
      );
    }
    return const Icon(null);  // Return an empty icon if no match is found
  }

  /// Default icon if no emotion is found for the day
  Widget _getDefaultIcon() {
    return const Icon(null);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.downBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                        height: screenHeight * 0.325,
                        decoration: BoxDecoration(
                          color: AppColors.upBackgroundColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.05,
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        height: screenHeight * 0.57,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TableCalendar(
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: titleBlack.copyWith(
                                  fontSize: screenHeight * 0.025),
                            ),
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                  fontSize: 12, color: Colors.black),
                              weekendStyle: TextStyle(
                                  fontSize: 12, color: Colors.black),
                            ),
                            firstDay: DateTime.utc(1800, 1, 1),
                            lastDay: DateTime.utc(2500, 12, 31),
                            focusedDay: _selectedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: _onDaySelected,
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                DateTime normalizedDay = DateTime(
                                    day.year, day.month, day.day);

                                return Container(
                                  height: 80,
                                  margin: const EdgeInsets.all(4.0),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _emotionMap.containsKey(normalizedDay)
                                          ? _getEmotionIcon(
                                          _emotionMap[normalizedDay]!)
                                          : _getDefaultIcon(),
                                      Text(
                                        '${day.day}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My emotions',
                              style: titleBlack.copyWith(
                                  fontSize: screenHeight * 0.025),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to the desired page
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textColorGrey,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View More',
                                    style: greySmallText.copyWith(
                                        fontSize: screenHeight * 0.018),
                                  ),
                                  SizedBox(width: 4.0),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: screenHeight * 0.02,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Emotion display logic (remains unchanged)
                      Container(
                        height: screenHeight * 0.1,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Example of using Emotion model for display
                            EmotionDisplay(
                              emotionContainerColor: AppColors.happyContainer,
                              emotionIcon: Image.asset('assets/emotion/happy.png'),
                              emotionText: 'Happy',
                              time: DateTime.now(),
                            ),
                            // Add more EmotionDisplay widgets
                          ],
                        ),
                      ),
                      // Music recommendation section
                      Padding(
                        padding: const EdgeInsets.only(top: 15, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Music Recommendations',
                              style: titleBlack.copyWith(
                                  fontSize: screenHeight * 0.025),
                            ),

                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
