import 'package:flutter/material.dart';
import 'package:send_snap/Data/Models/expense_model.dart';

class DashboardCard extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const DashboardCard({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final total = expenses.fold<num>(
      0,
      (previousValue, element) => previousValue + element.total,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Total Expenses",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text("\\${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
