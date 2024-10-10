import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmotionTrendLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> emotionData;


  const EmotionTrendLineChart({Key? key, required this.emotionData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 10.0, right: 10.0),
      child: Container(
        height: screenHeight * 0.3,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
        ),
        child: LineChart(
          LineChartData(
            minY: -6,  // Adjust Y-axis range if necessary
            maxY: 6,   // Adjust Y-axis range if necessary
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: _buildBottomTitles,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, getTitlesWidget: _buildLeftTitles),
              ),
            ),
            lineBarsData: [_buildLineBarData()],
            gridData: FlGridData(show: false),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> spots) {
                  return spots.map((spot) {
                    final timestamp = (emotionData[spot.x.toInt()]['timestamp'] as Timestamp).toDate();

                    // Format the timestamp to dd/MM HH:mm:ss
                    String formattedDate = DateFormat('dd/MM \nHH:mm:ss').format(timestamp);

                    return LineTooltipItem(
                      formattedDate, // Use the formatted date in the tooltip
                      greySmallText.copyWith(
                        fontSize: 10,
                        color: AppColors.textColorBlack,
                        backgroundColor: Colors.transparent,
                      ),
                    );
                  }).toList();
                },
                getTooltipColor: (touchedSpot) {
                  return AppColors.downBackgroundColor;
                },
                tooltipRoundedRadius: 8.0,
              ),
            ),

            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 0,
                  color: AppColors.upBackgroundColor,
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildLineBarData() {
    List<FlSpot> spots = [];

    // Populate spots based on the emotionData and valence
    for (var i = 0; i < emotionData.length; i++) {
      final emotion = emotionData[i]['emotion'];
      double valence = _getEmotionValence(emotion);

      spots.add(FlSpot(i.toDouble(), valence));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      dotData: FlDotData(show: true),
      color: AppColors.darkPurpleColor,
      belowBarData: BarAreaData(
        show: true,
        color: (spots.any((spot) => spot.y > 0)
            ? AppColors.fearContainer
            : AppColors.happyContainer),
      ),
    );
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

  Widget _buildBottomTitles(double value, TitleMeta meta) {
    // Assuming the first and last indices represent the start and end of the week
    if (value == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          '${(emotionData.first['timestamp'] as Timestamp).toDate().day}/${(emotionData.first['timestamp'] as Timestamp).toDate().month}',
          style: titleBlack.copyWith(fontSize: 10),
        ),
      );
    } else if (value == (emotionData.length - 1).toDouble()) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          '${(emotionData.last['timestamp'] as Timestamp).toDate().day}/${(emotionData.last['timestamp'] as Timestamp).toDate().month}',
          style: titleBlack.copyWith(fontSize: 10),
        ),
      );
    }
    return Container(); // Return empty for intermediate values
  }

  Widget _buildLeftTitles(double value, TitleMeta meta) {
    return Text(
      value.toString(),
      style: titleBlack.copyWith(fontSize: 10),
    );
  }
}
