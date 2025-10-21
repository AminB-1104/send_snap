// lib/UI/Pages/home_page.dart (or wherever HomePage is)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/Services/hive_service.dart';
import 'package:send_snap/UI/Components/appbar.dart';
import 'package:send_snap/UI/Components/dashboard_card.dart';
import 'package:send_snap/UI/Components/chip_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CategoryModel? selectedCategory;

  int selectedMonth = DateTime.now().month;
  String selectedFilter = 'Today'; // default selected chip

  @override
  void initState() {
    super.initState();
    // No longer storing filteredExpenses in state — we compute it live in the builder
  }

  // Helper to compute the date range based on selectedFilter and selectedMonth
  DateTimeRange _computeRange(DateTime now) {
    late DateTime start;
    late DateTime end;

    switch (selectedFilter) {
      case 'Week':
        final weekday = now.weekday; // monday=1
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
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
        break;
    }

    return DateTimeRange(start: start, end: end);
  }

  // filters a list of expenses by date range + category (if selected)
  List<ExpenseModel> _applyFilters(List<ExpenseModel> allExpenses) {
    final now = DateTime.now();
    final range = _computeRange(now);

    final results = allExpenses.where((e) {
      final d = e.date;
      final inRange =
          (d.isAtSameMomentAs(range.start) || d.isAfter(range.start)) &&
          (d.isBefore(range.end) || d.isAtSameMomentAs(range.end));
      if (!inRange) return false;

      if (selectedCategory == null) return true;
      return e.category == selectedCategory!.name;
    }).toList();

    return results;
  }

  void _onMonthChanged(int month) {
    setState(() => selectedMonth = month);
    // No further action needed; the ValueListenableBuilder will rebuild and call _applyFilters
  }

  void _onFilterChanged(String filter) {
    setState(() => selectedFilter = filter);
    // UI rebuilds automatically
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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

            // compute filtered list live (so Hive updates are reflected immediately)
            final visibleExpenses = _applyFilters(allExpenses);

            return CustomScrollView(
              slivers: [
                // --- DASHBOARD CARD ---
                SliverToBoxAdapter(child: DashboardCard(expenses: allExpenses)),

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
                    child: Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
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
                                boxShadow: [
                                  if (!isDark)
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading:
                                    expense.imagepath.isNotEmpty &&
                                        File(expense.imagepath).existsSync()
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(expense.imagepath),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 25,
                                        backgroundColor: const Color(
                                          0xFFEEE5FF,
                                        ),
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
                                title: Text(
                                  expense.merchant,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  expense.date.toLocal().toString().split(
                                    ' ',
                                  )[0],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: Text(
                                  "${expense.currency} ${expense.total.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7F3DFF),
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7F3DFF),
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ... keep your existing helper dialogs (unchanged) ...
  void _showAddExpenseDialog(BuildContext context) {
    // unchanged
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add an Expense'),
          content: const Text('How would you like to add an expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/imagegallery');
              },
              child: const Text('From Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/imagecamera');
              },
              child: const Text('Use Camera'),
            ),
          ],
        );
      },
    );
  }

  void _showExpenseDetails(BuildContext context, ExpenseModel expense) {
    // unchanged
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
