import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Services/firestore_service.dart';
import '../model/task_model.dart';

class DashboardScreen extends StatelessWidget {
  final Color creamBackground = const Color(0xFFFFF9F0);
  final Color goldColor = const Color(0xFFD4AF37);
  final Color lightGold = const Color(0xFFF5E1A4);
  final Color lightGreen = const Color(0xFF7BC47F);
  final Color darkRed = const Color(0xFF8B0000);

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: creamBackground,
        elevation: 0,
        title: Text(
          "Dashboard",
          style: TextStyle(color: goldColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Task>>(
        stream: Provider.of<FirestoreService>(context).getTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: goldColor));
          }

          final tasks = snapshot.data!;
          final total = tasks.length;
          final completed = tasks.where((t) => t.isCompleted).length;
          final pending = total - completed;
          final progress = total == 0 ? 0.0 : (completed / total) * 100;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Yo ho! Let’s see your progress 🏴‍☠️",
                  style: TextStyle(
                    color: goldColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: total.toDouble() + 1,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              switch (value.toInt()) {
                                case 0:
                                  return Text("Total", style: TextStyle(color: goldColor));
                                case 1:
                                  return Text("Completed", style: TextStyle(color: lightGreen));
                                case 2:
                                  return Text("Pending", style: TextStyle(color: darkRed));
                              }
                              return Text("");
                            },
                            reservedSize: 28,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [
                          BarChartRodData(
                            toY: total.toDouble(),
                            color: goldColor,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(
                            toY: completed.toDouble(),
                            color: lightGreen,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ]),
                        BarChartGroupData(x: 2, barRods: [
                          BarChartRodData(
                            toY: pending.toDouble(),
                            color: darkRed,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Progress Rate",
                  style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress / 100,
                        strokeWidth: 10,
                        backgroundColor: goldColor.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(lightGreen),
                      ),
                      Text(
                        "${progress.toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: goldColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
