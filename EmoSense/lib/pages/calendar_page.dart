import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.05
          ),
          child: Column(
            children: [
              TableCalendar(
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: titleBlack.copyWith(fontSize: screenHeight * 0.025),
                ),
                firstDay: DateTime.utc(1800, 1, 1),
                lastDay: DateTime.utc(2500, 12, 31),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusDay) {
                    DateTime normalizedDay =
                    DateTime(day.year, day.month, day.day);
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
              ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Container(
                  child: Text(
                    _selectedEmotion != null ? 'Emotion: $_selectedEmotion' : 'Emotion: None',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}