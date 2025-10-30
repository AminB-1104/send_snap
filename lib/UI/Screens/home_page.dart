// lib/UI/Pages/home_page.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/Services/hive_service.dart';
import 'package:send_snap/UI/Components/appbar.dart';
import 'package:send_snap/UI/Components/bottombar.dart';
import 'package:send_snap/UI/Components/dashboard_card.dart';
import 'package:send_snap/UI/Components/chip_selector.dart';
import 'package:send_snap/UI/Components/expense_line_chart.dart';
import 'package:send_snap/UI/Screens/add_expenses.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CategoryModel? selectedCategory;
  int selectedMonth = DateTime.now().month;
  String selectedFilter = 'Today'; //default filter

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
    // final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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

            return LiquidPullToRefresh(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 800));
                setState(() {});
              },
              color: theme.colorScheme.primary,
              backgroundColor: Colors.white,
              showChildOpacityTransition: false,
              height: 200,
              animSpeedFactor: 3,
              child: CustomScrollView(
                slivers: [
                  // DASHBOARD CARD
                  SliverToBoxAdapter(
                    child: DashboardCard(expenses: allExpenses),
                  ),

                  // EXPENSE LINE CHART
                  SliverToBoxAdapter(
                    child: ExpenseLineChart(
                      expenses: allExpenses, // pass ALL expenses
                      selectedFilter: _mapFilterStringToEnum(selectedFilter),
                    ),
                  ),
                  SliverToBoxAdapter(child: const SizedBox(height: 40)),

                  // FILTER SELECTOR (chips)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 60,
                      child: FilterSelector(
                        selectedFilter: selectedFilter,
                        onFilterChanged: _onFilterChanged,
                      ),
                    ),
                  ),

                  // RECENT TRANSACTIONS TITLE
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
                              color: theme.textTheme.bodyLarge!.color,
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
                            child: Text(
                              "See all",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
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
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
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
                                  color: theme.colorScheme.surface,
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
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.primary,
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
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          backgroundColor: theme.colorScheme.primary,
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
    final category = HiveService.categories.values.firstWhere(
      (c) => c.name == expense.category,
      orElse: () =>
          CategoryModel(id: 0, name: "?", iconsvg: "", iconcolor: 0xFF7F3DFF),
    );

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Category Icon
              Container(
                width: 60,
                height: 60,
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
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Amount
              Text(
                "${expense.currency} ${expense.total.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: category.color,
                ),
              ),
              const SizedBox(height: 4),

              // Merchant / Note
              Text(
                expense.merchant.isNotEmpty
                    ? expense.merchant
                    : expense.note.isNotEmpty
                    ? expense.note
                    : expense.category,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // Optional Image
              if (expense.imagepath.isNotEmpty &&
                  File(expense.imagepath).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(expense.imagepath),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 20),

              // Date and Category info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoTile(
                    "Date",
                    expense.date.toLocal().toString().split(' ')[0],
                  ),
                  _infoTile("Category", expense.category),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddExpensePage(expenseToEdit: expense),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Color(0xFF7F3DFF),
                        side: const BorderSide(color: Color(0xFF7F3DFF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: SvgPicture.asset(
                        "assets/icons/edit.svg",
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: const Text(
                        "Edit",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(context, expense);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFD3C4A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: SvgPicture.asset(
                        "assets/icons/trash.svg",
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: const Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xAA91919F),
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Expense"),
          content: const Text(
            "Are you sure you want to delete this expense? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                HiveService.deleteExpense(expense);
                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Color(0xFFFD3C4A)),
              ),
            ),
          ],
        );
      },
    );
  }
}
