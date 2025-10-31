import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/Services/hive_service.dart';
import 'package:send_snap/UI/Components/bottombar.dart';
import 'package:send_snap/UI/Components/month_dropdown.dart';
import 'package:send_snap/UI/Screens/add_expenses.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  List<ExpenseModel>? _filteredExpenses;
  int selectedMonth = DateTime.now().month;

  // Cache for performance
  Map<String, CategoryModel> _categoryCache = {};

  @override
  void initState() {
    super.initState();
    _buildCategoryCache();
  }

  void _buildCategoryCache() {
    _categoryCache = {
      for (var cat in HiveService.categories.values) cat.name: cat,
    };
  }

  void _openFilterModal() {
    final theme = Theme.of(context);
    String? selectedCategory;
    String? selectedSort;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final categories = HiveService.categories.values.toList();

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              const sortOptions = ['Newest', 'Oldest', 'Highest', 'Lowest'];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Filter & Sort",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Sort by",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: sortOptions.map((option) {
                          final isSelected = selectedSort == option;
                          return ChoiceChip(
                            backgroundColor: const Color(0xAAEEE5FF),
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            side: BorderSide.none,
                            label: Text(option),
                            selected: isSelected,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF7F3DFF)
                                  : Colors.black,
                            ),
                            onSelected: (_) {
                              setModalState(() {
                                selectedSort = option;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "Filter by Category",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: categories.map((cat) {
                          final isSelected = selectedCategory == cat.name;
                          return ChoiceChip(
                            backgroundColor: const Color(0xAAEEE5FF),
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            side: BorderSide.none,
                            label: Text(cat.name),
                            selected: isSelected,
                            selectedColor: cat.color.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? cat.color : Colors.black,
                            ),
                            onSelected: (_) {
                              setModalState(() {
                                selectedCategory = cat.name;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7F3DFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _applyFilters(selectedCategory, selectedSort);
                          },
                          child: const Text(
                            "Apply Filters",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _applyFilters(String? category, String? sortOption) {
    final box = HiveService.expenses;
    List<ExpenseModel> filtered = box.values.toList();

    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((e) => e.category == category).toList();
    }

    if (selectedMonth != 0) {
      filtered = filtered.where((e) => e.date.month == selectedMonth).toList();
    }

    switch (sortOption) {
      case 'Newest':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Highest':
        filtered.sort((a, b) => b.total.compareTo(a.total));
        break;
      case 'Lowest':
        filtered.sort((a, b) => a.total.compareTo(b.total));
        break;
    }

    setState(() {
      _filteredExpenses = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: theme.appBarTheme.backgroundColor,
        leading: IconButton(
          onPressed: () => context.pushNamed('/home'),
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            colorFilter: ColorFilter.mode(
              theme.iconTheme.color!,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MonthDropdown(
              selectedMonth: selectedMonth,
              onMonthChanged: (month) {
                setState(() {
                  selectedMonth = month;
                });
                _applyFilters(null, null);
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/sort.svg',
              colorFilter: ColorFilter.mode(
                theme.iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
            onPressed: _openFilterModal,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.expenses.listenable(),
        builder: (context, Box<ExpenseModel> box, _) {
          final allExpenses = _filteredExpenses ?? box.values.toList();

          if (allExpenses.isEmpty) {
            return const Center(
              child: Text(
                "No expenses added yet.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return LiquidPullToRefresh(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 800));
              setState(() {
                _buildCategoryCache();
              });
            },
            color: const Color(0xFF7F3DFF),
            backgroundColor: theme.colorScheme.surface,
            showChildOpacityTransition: false,
            height: 200,
            animSpeedFactor: 3,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: allExpenses.length,
              cacheExtent: 200,
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
              itemBuilder: (context, index) {
                final expense = allExpenses[index];
                final category =
                    _categoryCache[expense.category] ??
                    CategoryModel(
                      id: 0,
                      name: "?",
                      iconsvg: "",
                      iconcolor: 0xFF7F3DFF,
                    );

                return _TransactionTile(
                  key: ValueKey(expense.id),
                  expense: expense,
                  category: category,
                  theme: theme,
                  onTap: () => _showExpenseDetails(context, expense),
                );
              },
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          backgroundColor: theme.colorScheme.primary,
          elevation: 0,
          shape: const CircleBorder(),
          onPressed: () => context.pushNamed('/addExpense'),
          child: Transform.rotate(
            angle: 25 * math.pi / 100,
            child: SvgPicture.asset(
              width: 40,
              height: 40,
              'assets/icons/close.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  void _showExpenseDetails(BuildContext context, ExpenseModel expense) {
    final theme = Theme.of(context);
    final category =
        _categoryCache[expense.category] ??
        CategoryModel(id: 0, name: "?", iconsvg: "", iconcolor: 0xFF7F3DFF);

    showModalBottomSheet(
      backgroundColor: theme.colorScheme.surface,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          _ExpenseDetailModal(expense: expense, category: category),
    );
  }
}

// Extracted tile widget
class _TransactionTile extends StatelessWidget {
  final ExpenseModel expense;
  final CategoryModel category;
  final ThemeData theme;
  final VoidCallback onTap;

  const _TransactionTile({
    super.key,
    required this.expense,
    required this.category,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
          onTap: onTap,
        ),
      ),
    );
  }
}

// Extracted modal
class _ExpenseDetailModal extends StatelessWidget {
  final ExpenseModel expense;
  final CategoryModel category;

  const _ExpenseDetailModal({required this.expense, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
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
                colorFilter: ColorFilter.mode(category.color, BlendMode.srcIn),
                width: 30,
                height: 30,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${expense.currency} ${expense.total.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: category.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            expense.merchant.isNotEmpty
                ? expense.merchant
                : expense.note.isNotEmpty
                ? expense.note
                : expense.category,
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium!.color,
            ),
          ),
          const SizedBox(height: 16),
          if (expense.imagepath.isNotEmpty &&
              File(expense.imagepath).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(expense.imagepath),
                height: 400,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 800,
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoTile(
                "Date",
                expense.date.toLocal().toString().split(' ')[0],
              ),
              _InfoTile("Category", expense.category),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddExpensePage(expenseToEdit: expense),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF7F3DFF),
                    side: const BorderSide(color: Color(0xFF7F3DFF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: SvgPicture.asset(
                    "assets/icons/edit.svg",
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
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
                    colorFilter: const ColorFilter.mode(
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
  }

  void _confirmDelete(BuildContext context, ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF91919F), fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );
  }
}
