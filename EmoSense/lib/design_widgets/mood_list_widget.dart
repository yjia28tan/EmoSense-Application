import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:emosense/design_widgets/font_style.dart';

class MoodListWidget extends StatelessWidget {
  final List<DocumentSnapshot> moodRecords;
  final Function(String) onDelete;

  MoodListWidget({
    required this.moodRecords,
    required this.onDelete,
  });

  Image? getMoodIcon(String mood) {
    switch (mood) {
      case 'Happy':
        return Image.asset('assets/happy.png', width: 40, height: 40);
      case 'Angry':
        return Image.asset('assets/angry.png', width: 40, height: 40);
      case 'Neutral':
        return Image.asset('assets/neutral.png', width: 40, height: 40);
      case 'Sad':
        return Image.asset('assets/sad.png', width: 40, height: 40);
      case 'Fear':
        return Image.asset('assets/fear.png', width: 40, height: 40);
      case 'Disgust':
        return Image.asset('assets/disgust.png', width: 40, height: 40);
      default:
        return Image.asset('assets/logo.png', width: 40, height: 40);;
    }
  }


  String formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: moodRecords.length,
      itemBuilder: (context, index) {
        var record = moodRecords[index];
        var mood = record['mood'] ?? 'Unknown';
        var description = record['description'] ?? 'No description';
        var timestamp = (record['timestamp'] as Timestamp).toDate();

        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: InkWell(
            onTap: () {
              // Navigator.push(
              // context,
              // MaterialPageRoute(
              //   builder: (context) => MoodDetailsPage(moodId: record.id),
              // ),
              // );
            },
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Color(0xFFE5FFD0).withOpacity(0.8),
                  child: ListTile(
                    leading: getMoodIcon(mood) ?? Image.asset(
                      'assets/default.png', // Path to default image if mood doesn't match
                      width: 40,
                      height: 40,
                    ),
                    title: Text(
                      '${formatTimestamp(timestamp)}',
                      style: whiteText,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$mood',
                          style: GoogleFonts.leagueSpartan(
                            color: Color(0xFF366021),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$description',
                          style: TextStyle(
                            color: Color(0xFF366021),
                          ),
                        ),
                      ],
                    ),

                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Color(0xFF366021)),
                      onPressed: () => onDelete(record.id),
                    ),
                  ),
                ),
                SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }
}