import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
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
    _fetchDataForSelectedDay();
    _fetchAllEmotions();
  }

  Future<void> _fetchDataForSelectedDay() async {
    final uid = globalUID;
    final startOfDay =
    DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final emotionSnapshot = await FirebaseFirestore.instance
        .collection('emotionRecord')
        .where('uid', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .limit(1)
        .get();

    String? mood;
    if (emotionSnapshot.docs.isNotEmpty) {
      mood = emotionSnapshot.docs.first['emotion'];
    }

    setState(() {
      _selectedEmotion = mood;
    });
  }

  Future<void> _fetchAllEmotions() async {
    final uid = globalUID;

    final moodSnapshot = await FirebaseFirestore.instance
        .collection('emotionRecord')
        .where('uid', isEqualTo: uid)
        .get();

    Map<DateTime, String> emotionMap = {};
    for (var doc in moodSnapshot.docs) {
      DateTime date = (doc['timestamp'] as Timestamp).toDate();
      emotionMap[DateTime(date.year, date.month, date.day)] = doc['emotion'];
    }

    setState(() {
      _emotionMap = emotionMap;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
    _fetchDataForSelectedDay();
  }

  Icon _getMoodIcon(String mood) {
    switch (mood) {
      case 'Happy':
        return const Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.green,
          size: 25,
        );
      case 'Neutral':
        return const Icon(
          Icons.sentiment_satisfied,
          color: Colors.lightGreen,
          size: 25,
        );
      case 'Disgust':
        return const Icon(
          Icons.sentiment_neutral,
          color: Colors.amber,
          size: 25,
        );
      case 'Fear':
        return const Icon(
          Icons.sentiment_dissatisfied,
          color: Colors.orange,
          size: 25,
        );
      case 'Angry':
        return const Icon(
          Icons.sentiment_very_dissatisfied,
          color: Colors.red,
          size: 25,
        );
      case 'Sad':
        return const Icon(
          Icons.sentiment_dissatisfied_rounded,
          color: Colors.blue,
          size: 25,
        );
      default:
        return const Icon(null);
    }
  }

  Icon _getDefaultIcon() {
    return const Icon(null);
    // return const Icon(
    //   Icons.sentiment_dissatisfied_rounded,
    //   color: Colors.blue,
    //   size: 25,
    // );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // set the background color of the page
      backgroundColor: AppColors.downBackgroundColor,
      body: Stack(
        children: [
          Container(
           // Background color matching the design
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
              vertical: screenHeight * 0.05
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.all(Radius.circular(30),
                  ),
                ),
                height: screenHeight * 0.57,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TableCalendar(
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: titleBlack.copyWith(fontSize: screenHeight * 0.025),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontSize: 12, color: Colors.black), // Customize as needed
                      weekendStyle: TextStyle(fontSize: 12, color: Colors.black), // Customize as needed
                    ),
                    firstDay: DateTime.utc(1800, 1, 1),
                    lastDay: DateTime.utc(2500, 12, 31),
                    focusedDay: _selectedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        DateTime normalizedDay = DateTime(day.year, day.month, day.day);

                        return Container(
                          height: 80,
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _emotionMap.containsKey(normalizedDay)
                                  ? _getMoodIcon(_emotionMap[normalizedDay]!)
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
                  )

                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'My Mood',
                          style: titleBlack.copyWith(fontSize: screenHeight * 0.025),
                        ),
                      ),
                    ),
                    Container(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to the desired page
                          // Navigator.pushNamed(context, '/mood');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textColorGrey,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View More',
                              style: greySmallText.copyWith(fontSize: screenHeight * 0.018),
                            ),
                            SizedBox(width: 4.0), // Add space between text and icon
                            Icon(
                              Icons.arrow_forward,
                              size: screenHeight * 0.02,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
        ],
      ),
    );
  }
}