import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EmotionTrendLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> emotionData;

  const EmotionTrendLineChart({Key? key, required this.emotionData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 10.0, right: 10.0), // Increased bottom padding
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
                sideTitles: SideTitles(showTitles: false), // Remove top titles
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Remove right titles
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30, // Reserve more space for bottom titles
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
                    return LineTooltipItem(
                      '${spot.y.toInt()}',
                      greySmallText.copyWith(
                        fontSize: 16,
                        color: AppColors.textColorBlack,
                        backgroundColor: Colors.transparent, // Text background color (optional)
                      ),
                    );
                  }).toList();
                },
                getTooltipColor: (touchedSpot) {
                  return Colors.transparent; // Set tooltip background color to transparent
                },
                tooltipRoundedRadius: 8.0, // Customize the tooltip radius if needed
              ),
            ),


            // Add horizontal line at y = 0
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 0, // Position the line at y = 0
                  color: AppColors.upBackgroundColor, // Define the color of the horizontal line
                  strokeWidth: 2, // Set the thickness of the line
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

      // Convert emotion to valence
      double valence = _getEmotionValence(emotion) as double;

      // Create FlSpot with the x-value as index and y-value as valence
      spots.add(FlSpot(i.toDouble(), valence));
    }

    return LineChartBarData(
        spots: spots,
        isCurved: true,
        dotData: FlDotData(show: true),
    color: AppColors.darkPurpleColor, // Define the color of the line
    belowBarData: BarAreaData(
    show: true,
    color: (spots.any((spot) => spot.y > 0) // Change this logic based on your requirement
    ? AppColors.fearContainer // Color for the area below y=0
        : AppColors.happyContainer), // Color for the area above y=0
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
    // Fetch the timestamp from the emotionData and convert it to DateTime
    final timestamp = (emotionData[value.toInt()]['timestamp'] as Timestamp).toDate();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        '${timestamp.day}/${timestamp.month}',
        style: titleBlack.copyWith(fontSize: 10),
      ),
    );
  }

  Widget _buildLeftTitles(double value, TitleMeta meta) {
    return Text(
      value.toString(),
      style: titleBlack.copyWith(fontSize: 10),
    );
  }
}
