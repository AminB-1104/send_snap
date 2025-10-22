// lib/UI/Pages/home_page.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/Services/hive_service.dart';
import 'package:send_snap/UI/Components/appbar.dart';
import 'package:send_snap/UI/Components/bottombar.dart';
import 'package:send_snap/UI/Components/dashboard_card.dart';
import 'package:send_snap/UI/Components/chip_selector.dart';
import 'package:send_snap/UI/Components/expense_line_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CategoryModel? selectedCategory;
  int selectedMonth = DateTime.now().month;
  String selectedFilter = 'Today'; // default selected chip

  void _onMonthChanged(int month) {
    setState(() => selectedMonth = month);
  }

  void _onFilterChanged(String filter) {
    setState(() => selectedFilter = filter);
  }

  ExpenseFilter _mapFilterStringToEnum(String filter) {
    switch (filter) {
      case 'Today':
        return ExpenseFilter.today;
      case 'Week':
        return ExpenseFilter.week;
      case 'Month':
        return ExpenseFilter.month;
      case 'Year':
        return ExpenseFilter.year;
      default:
        return ExpenseFilter.week;
    }
  }

  // filters a list of expenses by date range + category (for recent transactions)
  List<ExpenseModel> _applyFilters(List<ExpenseModel> allExpenses) {
    final now = DateTime.now();

    late DateTime start;
    late DateTime end;

    switch (selectedFilter) {
      case 'Week':
        final weekday = now.weekday;
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: weekday - 1));
        end = start.add(const Duration(days: 7));
        break;

      case 'Month':
        start = DateTime(now.year, selectedMonth, 1);
        end = (selectedMonth == 12)
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, selectedMonth + 1, 1);
        break;

      case 'Year':
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year + 1, 1, 1);
        break;

      default: // Today
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
    }

    return allExpenses.where((e) {
      final d = e.date;
      final inRange =
          (d.isAtSameMomentAs(start) || d.isAfter(start)) &&
          (d.isBefore(end) || d.isAtSameMomentAs(end));

      if (!inRange) return false;
      if (selectedCategory == null) return true;
      return e.category == selectedCategory!.name;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HomeAppBar(
        profileImage: 'assets/images/avatar.png',
        selectedMonth: selectedMonth,
        onMonthChanged: _onMonthChanged,
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: HiveService.expenses.listenable(),
          builder: (context, Box<ExpenseModel> box, _) {
            final allExpenses = box.values.toList().cast<ExpenseModel>();
            final visibleExpenses = _applyFilters(allExpenses);

            return CustomScrollView(
              slivers: [
                // --- DASHBOARD CARD ---
                SliverToBoxAdapter(child: DashboardCard(expenses: allExpenses)),

                // --- EXPENSE LINE CHART ---
                SliverToBoxAdapter(
                  child: ExpenseLineChart(
                    expenses: allExpenses, // pass ALL expenses
                    selectedFilter: _mapFilterStringToEnum(selectedFilter),
                  ),
                ),

                // --- FILTER SELECTOR (chips) ---
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 60,
                    child: FilterSelector(
                      selectedFilter: selectedFilter,
                      onFilterChanged: _onFilterChanged,
                    ),
                  ),
                ),

                // --- RECENT TRANSACTIONS TITLE ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Transactions",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.pushNamed('/transactions');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            backgroundColor: const Color(0xffEEE5FF),
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "See all",
                            style: TextStyle(
                              color: Color(0xFF7F3DFF),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- TRANSACTION LIST ---
                visibleExpenses.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            "No expenses yet.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final expense = visibleExpenses[index];
                          final category = HiveService.categories.values
                              .firstWhere(
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
                                color: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: category.color.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: category.iconsvg.isNotEmpty
                                      ? Center(
                                          child: SvgPicture.asset(
                                            category.iconsvg,
                                            colorFilter: ColorFilter.mode(
                                              category.color,
                                              BlendMode.srcIn,
                                            ),
                                            width: 28,
                                            height: 28,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            expense.category.isNotEmpty
                                                ? expense.category[0]
                                                      .toUpperCase()
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
                                  expense.note.isNotEmpty
                                      ? expense.note
                                      : expense.merchant,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: Text(
                                  "- ${expense.total.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFD3C4A),
                                  ),
                                ),
                                onTap: () =>
                                    _showExpenseDetails(context, expense),
                              ),
                            ),
                          );
                        }, childCount: visibleExpenses.length),
                      ),
              ],
            );
          },
        ),
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
      builder: (context) => AlertDialog(
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
              Text('Date: ${expense.date.toLocal().toString().split(' ')[0]}'),
              Text('Category: ${expense.category}'),
              if (expense.note.isNotEmpty) Text('Note: ${expense.note}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
