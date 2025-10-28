import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:send_snap/Data/Models/expense_model.dart';

class DashboardCard extends StatelessWidget {
  final List<ExpenseModel> expenses;

  final income = 5000;

  const DashboardCard({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final total = expenses.fold<num>(
      0,
      (previousValue, element) => previousValue + element.total,
    );

    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Account Balance",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${income - total}",
              // "\$${total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.black,
                fontSize: 40,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Income vs Expense summary (just like Figma)
            // Padding(
            // padding: const EdgeInsets.symmetric(horizontal: 1.0),
            // child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF00A86B),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              'assets/icons/income.svg',
                              width: 32,
                              height: 32,
                              colorFilter: ColorFilter.mode(
                                Color(0xFF00A86B),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Income',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '\$$income',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFD3C4A),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              'assets/icons/income.svg',
                              width: 32,
                              height: 32,
                              colorFilter: ColorFilter.mode(
                                Color(0xFFFD3C4A),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expenses',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
