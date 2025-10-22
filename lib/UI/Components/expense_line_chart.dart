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
          return expDate.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
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

    final spots = grouped.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    if (spots.isEmpty) spots.add(const FlSpot(0, 0));

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getChartSpots();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF7F3DFF),
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF7F3DFF).withOpacity(0.2),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
