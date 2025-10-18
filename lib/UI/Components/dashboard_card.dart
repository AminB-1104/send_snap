import 'package:flutter/material.dart';
import 'package:send_snap/Data/Models/expense_model.dart';

class DashboardCard extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const DashboardCard({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = expenses.fold<num>(
      0,
      (previousValue, element) => previousValue + element.total,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F3DFF), Color(0xFF9F7BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7F3DFF).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Balance",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Income vs Expense summary (just like Figma)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Income',
                  value: '+\$2,400.00', // placeholder, can be dynamic later
                  color: Colors.greenAccent,
                ),
                _buildStat(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Expense',
                  value: '-\$${total.toStringAsFixed(2)}',
                  color: Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          radius: 20,
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
