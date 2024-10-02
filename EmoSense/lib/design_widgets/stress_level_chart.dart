import 'package:emosense/design_widgets/stress_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HalfDonutChart extends StatelessWidget {
  final Map<String, int> stressCounts;

  HalfDonutChart({required this.stressCounts});

  @override
  Widget build(BuildContext context) {
    double total = stressCounts.values.reduce((a, b) => a + b).toDouble();
    List<FlSpot> spots = [];

    int index = 0;
    stressCounts.forEach((level, count) {
      if (count > 0) {
        spots.add(FlSpot(index.toDouble(), count.toDouble()));
      }
      index++;
    });

    return PieChart(
      PieChartData(
        sections: spots.map((spot) {
          return PieChartSectionData(
            value: spot.y,
            color: stressModels[spot.x.toInt()].color,
            title: '${spot.y.toInt()}',
            titleStyle: TextStyle(color: Colors.white, fontSize: 14),
          );
        }).toList(),
        borderData: FlBorderData(show: false),
        centerSpaceRadius: 10,
        sectionsSpace: 0,
      ),
    );
  }
}
