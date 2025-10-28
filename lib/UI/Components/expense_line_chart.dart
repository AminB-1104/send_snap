import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:send_snap/Data/Models/expense_model.dart';

enum ExpenseFilter { today, week, month, year }

class ExpenseLineChart extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final ExpenseFilter selectedFilter;

  const ExpenseLineChart({
    super.key,
    required this.expenses,
    required this.selectedFilter,
  });

  List<FlSpot> _getChartSpots() {
    final now = DateTime.now();
    final filteredExpenses = expenses.where((exp) {
      final expDate = exp.date;
      switch (selectedFilter) {
        case ExpenseFilter.today:
          return expDate.year == now.year &&
              expDate.month == now.month &&
              expDate.day == now.day;
        case ExpenseFilter.week:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));
          return expDate.isAfter(
                weekStart.subtract(const Duration(seconds: 1)),
              ) &&
              expDate.isBefore(weekEnd.add(const Duration(days: 1)));
        case ExpenseFilter.month:
          return expDate.year == now.year && expDate.month == now.month;
        case ExpenseFilter.year:
          return expDate.year == now.year;
      }
    }).toList();

    final Map<int, double> grouped = {};
    for (var exp in filteredExpenses) {
      int x;
      switch (selectedFilter) {
        case ExpenseFilter.today:
          x = exp.date.hour;
          break;
        case ExpenseFilter.week:
          x = exp.date.weekday;
          break;
        case ExpenseFilter.month:
          x = exp.date.day;
          break;
        case ExpenseFilter.year:
          x = exp.date.month;
          break;
      }
      grouped[x] = (grouped[x] ?? 0) + exp.total.toDouble();
    }

    final spots =
        grouped.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList()
          ..sort((a, b) => a.x.compareTo(b.x));

    if (spots.isEmpty) spots.add(const FlSpot(0, 0));

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getChartSpots();

    return SizedBox(
      height: 180,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: const Color(0xFF7F3DFF),
                barWidth: 6,
                dotData: FlDotData(show: false),
                isStrokeCapRound: true,
                isStrokeJoinRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 189, 156, 255),
                      Color.fromARGB(255, 189, 156, 255),
                      // Color.fromARGB(159, 213, 192, 255),
                      Color.fromARGB(11, 255, 255, 255),
                    ],
                    begin: AlignmentGeometry.topCenter,
                    end: AlignmentGeometry.bottomCenter,
                  ),
                  // color: const Color(0xFF7F3DFF).withOpacity(0.2),
                ),
                // preventCurveOverShooting: true,
              ),
            ],
            titlesData: FlTitlesData(
              show: false,
              // leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              // bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
