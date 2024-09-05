import 'package:cloud_firestore/cloud_firestore.dart';
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
  Map<DateTime, String> _moodMap = {};

  @override
  void initState() {
    super.initState();
    _fetchDataForSelectedDay();
    _fetchAllMoods();
  }

  Future<void> _fetchDataForSelectedDay() async {
    final uid = globalUID;
    final startOfDay =
    DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final moodSnapshot = await FirebaseFirestore.instance
        .collection('moodRecord')
        .where('uid', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .limit(1)
        .get();

    String? mood;
    if (moodSnapshot.docs.isNotEmpty) {
      mood = moodSnapshot.docs.first['mood'];
    }

    setState(() {
      _selectedEmotion = mood;
    });
  }

  Future<void> _fetchAllMoods() async {
    final uid = globalUID;

    final moodSnapshot = await FirebaseFirestore.instance
        .collection('moodRecord')
        .where('uid', isEqualTo: uid)
        .get();

    Map<DateTime, String> moodMap = {};
    for (var doc in moodSnapshot.docs) {
      DateTime date = (doc['timestamp'] as Timestamp).toDate();
      moodMap[DateTime(date.year, date.month, date.day)] = doc['mood'];
    }

    setState(() {
      _moodMap = moodMap;
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
          size: 21,
        );
      case 'Neutral':
        return const Icon(
          Icons.sentiment_satisfied,
          color: Colors.lightGreen,
          size: 21,
        );
      case 'Disgust':
        return const Icon(
          Icons.sentiment_neutral,
          color: Colors.amber,
          size: 21,
        );
      case 'Fear':
        return const Icon(
          Icons.sentiment_dissatisfied,
          color: Colors.orange,
          size: 21,
        );
      case 'Angry':
        return const Icon(
          Icons.sentiment_very_dissatisfied,
          color: Colors.red,
          size: 21,
        );
      case 'Sad':
        return const Icon(
          Icons.sentiment_dissatisfied_rounded,
          color: Colors.blue,
          size: 21,
        );
      default:
        return const Icon(null);
    }
  }

  Icon _getDefaultIcon() {
    return const Icon(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TableCalendar(
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
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
                          _moodMap.containsKey(normalizedDay)
                              ? _getMoodIcon(_moodMap[normalizedDay]!)
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