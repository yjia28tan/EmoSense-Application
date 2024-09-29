import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/emotion_model.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/emotion_display_box.dart';
import 'package:emosense/design_widgets/music_lists_widget.dart';
import 'package:emosense/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, String> _emotionMap = {};
  List<Map<String, dynamic>> _emotionListForSelectedDay = [];
  List<Map<String, dynamic>> _trackListForSelectedDay = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedDay = DateTime.now();
      _initializeFirebaseAndFetchData();
    });
  }

  Future<void> _initializeFirebaseAndFetchData() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Fetch data for today's date
    await _fetchDataForSelectedDay();
    await _fetchAllEmotions();
  }

  Future<void> _fetchAllEmotions() async {
    try {
      final uid = globalUID;

      // Fetch all emotion records for the user, ordered by timestamp descending
      final emotionSnapshot = await FirebaseFirestore.instance
          .collection('emotionRecords')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .get();

      print('Emotion snapshot: $emotionSnapshot');
      print('Emotion snapshot size: ${emotionSnapshot.docs.length}');

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

  Future<void> _fetchDataForSelectedDay() async {
    final uid = globalUID;
    final startOfDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final endOfDay = startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

    print("Start day: $startOfDay");
    print("End day: $endOfDay");

    final emotionSnapshot = await FirebaseFirestore.instance
        .collection('emotionRecords')
        .where('uid', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .get();

    List<Map<String, dynamic>> emotions = [];
    List<Map<String, dynamic>> tracks = []; // Store track data as maps

    if (emotionSnapshot.docs.isNotEmpty) {
      for (var doc in emotionSnapshot.docs) {
        // Add the emotions
        emotions.add({
          'emotion': doc['emotion'],
          'timestamp': doc['timestamp'],
        });

        // Fetch and add tracks if available
        if (doc['tracks'] != null) {
          final trackList = List<Map<String, dynamic>>.from(doc['tracks']);
          tracks.addAll(trackList); // Store track data as a map
        } else {
          print('No tracks found for this record.');
          }
      }
    }
    print(emotions);
    print(tracks);

    // Update the state with both emotions and tracks for the selected day
    setState(() {
      _emotionListForSelectedDay = emotions;
      _trackListForSelectedDay = tracks; // Store track maps
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
    _fetchDataForSelectedDay(); // Fetch data for the newly selected day
  }

  /// Adjusted this function to make the emoji size dynamic based on screen height
  Widget _getEmotionIcon(String mood, double iconSize) {
    final emotion = Emotion.emotions.firstWhere(
          (e) => e.name == mood,
      orElse: () => Emotion(
        name: 'Unknown',
        assetPath: 'assets/logo.png',
        color: Colors.transparent,
        containerColor: Colors.transparent,
      ),
    );

    return Image.asset(
      emotion.assetPath,
      width: iconSize,  // Set the size dynamically
    );
  }

  /// Default icon with adjustable size if no emotion is found
  Widget _getDefaultIcon(double iconSize) {
    return Image.asset(
      'assets/logo.png',
      width: iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenHeight * 0.045;

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
                      // Calendar Widget
                      Container(
                        height: screenHeight * 0.57,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
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
                            firstDay: DateTime.utc(2000, 1, 1),
                            lastDay: DateTime.utc(2500, 12, 31),
                            focusedDay: _selectedDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            onDaySelected: _onDaySelected,
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                DateTime normalizedDay = DateTime(day.year, day.month, day.day);
                                bool hasEmotion = _emotionMap.containsKey(normalizedDay);

                                return Container(
                                  height: 85,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent, // Default background
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      hasEmotion
                                          ? _getEmotionIcon(_emotionMap[normalizedDay]!, iconSize)
                                          : _getDefaultIcon(iconSize),
                                      Text(
                                        '${day.day}',
                                        style: greySmallText.copyWith(fontSize: screenHeight * 0.014),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              selectedBuilder: (context, day, focusedDay) {
                                DateTime normalizedDay = DateTime(day.year, day.month, day.day);
                                bool hasEmotion = _emotionMap.containsKey(normalizedDay);

                                return Container(
                                  height: 85,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.textFieldColor, // Gray background for the selected day
                                    border: Border.all(color: Colors.black, width: 0.5), // Border for the selected day
                                    borderRadius: BorderRadius.circular(10), // Rounded corners
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      hasEmotion
                                          ? _getEmotionIcon(_emotionMap[normalizedDay]!, iconSize)
                                          : _getDefaultIcon(iconSize),
                                      Text(
                                        '${day.day}',
                                        style: greySmallText.copyWith(fontSize: screenHeight * 0.014),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              todayBuilder: (context, day, focusedDay) {
                                DateTime normalizedDay = DateTime(day.year, day.month, day.day);
                                bool hasEmotion = _emotionMap.containsKey(normalizedDay);

                                return Container(
                                  height: 85,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.downBackgroundColor, // Grey background for today
                                    border: Border.all(color: Colors.transparent), // No border for today
                                    borderRadius: BorderRadius.circular(10), // Rounded corners
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      hasEmotion
                                          ? _getEmotionIcon(_emotionMap[normalizedDay]!, iconSize)
                                          : _getDefaultIcon(iconSize),
                                      Text(
                                        '${day.day}',
                                        style: greySmallText.copyWith(fontSize: screenHeight * 0.014),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),



                          ),
                        ),
                      ),

                      // Emotion Display Section
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('My emotions', style: titleBlack.copyWith(fontSize: screenHeight * 0.025)),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(foregroundColor: AppColors.textColorGrey),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('View More',
                                      style: greySmallText.copyWith(fontSize: screenHeight * 0.018)
                                  ),
                                  SizedBox(width: 4.0),
                                  Icon(Icons.arrow_forward, size: screenHeight * 0.02),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Display Emotions for the Selected Day
                      Container(
                        height: screenHeight * 0.1,
                        child: _emotionListForSelectedDay.isNotEmpty
                            ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _emotionListForSelectedDay.length,
                              itemBuilder: (context, index) {
                                final emotionData = _emotionListForSelectedDay[index];
                                final String emotionName = emotionData['emotion'];
                                final DateTime timestamp = (emotionData['timestamp'] as Timestamp).toDate();

                                // Fetch the corresponding emotion details
                                final emotionDetails = Emotion.emotions.firstWhere(
                                      (e) => e.name == emotionName,
                                  orElse: () => Emotion(name: 'Unknown', assetPath: 'assets/logo.png', color: Colors.grey, containerColor: Colors.grey.withOpacity(0.6)),
                                );

                                return EmotionDisplay(
                                  emotionContainerColor: emotionDetails.containerColor,
                                  emotionIcon: Image.asset(emotionDetails.assetPath),
                                  emotionText: emotionDetails.name,
                                  time: timestamp,
                                );
                              },
                            )
                            : Center(
                              child: Text('No emotions recorded for this day.',
                                  style: greySmallText.copyWith(fontSize: screenHeight * 0.022)),
                            ),
                      ),

                      // Music Recommendations Section
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 15, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Music Recommendations',
                              style: titleBlack.copyWith(fontSize: screenHeight * 0.025)
                          ),
                        ),
                      ),
                      Container(
                        height: _trackListForSelectedDay.isNotEmpty
                            ? screenHeight * 0.5 // Fixed height when tracks are available
                            : screenHeight * 0.12, // Lower height when no tracks are available
                        child: _trackListForSelectedDay.isNotEmpty
                            ? ListView.builder(
                          itemCount: _trackListForSelectedDay.length,
                          itemBuilder: (context, index) {
                            final track = _trackListForSelectedDay[index];
                            return MusicRecommendedLists(
                              musicImage: track['imageUrl'],
                              musicTitle: track['name'] ?? 'Unknown Track',
                              artist: track['artist'] ?? 'Unknown Artist',
                              trackId: track['id'] ?? 'unknown_id',
                            );
                          },
                        )
                            : Center(
                          child: Text(
                            'No tracks for this day.',
                            style: greySmallText.copyWith(fontSize: screenHeight * 0.022),
                          ),
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
