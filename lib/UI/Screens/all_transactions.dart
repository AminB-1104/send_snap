import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/Services/hive_service.dart';
import 'package:send_snap/UI/Components/appbar.dart';
import 'package:send_snap/UI/Components/bottombar.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  int selectedMonth = DateTime.now().month;

  void _onMonthChanged(int month) {
    setState(() => selectedMonth = month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            context.pushNamed('/home');
          },
          icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.expenses.listenable(),
        builder: (context, Box<ExpenseModel> box, _) {
          final allExpenses = box.values.toList().cast<ExpenseModel>();

          if (allExpenses.isEmpty) {
            return const Center(
              child: Text(
                "No expenses added yet.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: allExpenses.length,
            itemBuilder: (context, index) {
              final expense = allExpenses[index];

              final category = HiveService.categories.values.firstWhere(
                (c) => c.name == expense.category,
                orElse: () => CategoryModel(
                  id: 0,
                  name: "?",
                  iconsvg: "",
                  iconcolor: 0xFF7F3DFF,
                ),
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: category.iconsvg.isNotEmpty
                        ? Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                category.iconsvg,
                                colorFilter: ColorFilter.mode(
                                  category.color,
                                  BlendMode.srcIn,
                                ),
                                width: 28,
                                height: 28,
                              ),
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                expense.category.isNotEmpty
                                    ? expense.category[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                  color: Color(0xFF7F3DFF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                    title: Text(
                      expense.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      expense.note.isNotEmpty ? expense.note : expense.merchant,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    trailing: Text(
                      "- ${expense.total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFD3C4A),
                      ),
                    ),
                    onTap: () => _showExpenseDetails(context, expense),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF7F3DFF),
          elevation: 0,
          shape: const CircleBorder(),
          onPressed: () {
            context.pushNamed('/addExpense');
          },
          child: Transform.rotate(
            angle: 25 * math.pi / 100,
            child: SvgPicture.asset(
              width: 40,
              height: 40,
              'assets/icons/close.svg',
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }

  void _showExpenseDetails(BuildContext context, ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(expense.merchant),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (expense.imagepath.isNotEmpty &&
                    File(expense.imagepath).existsSync())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Image.file(File(expense.imagepath)),
                  ),
                Text(
                  'Total: ${expense.currency} ${expense.total.toStringAsFixed(2)}',
                ),
                Text(
                  'Date: ${expense.date.toLocal().toString().split(' ')[0]}',
                ),
                Text('Category: ${expense.category}'),
                if (expense.note.isNotEmpty) Text('Note: ${expense.note}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
