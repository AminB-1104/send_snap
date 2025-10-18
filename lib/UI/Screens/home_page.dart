import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/Services/hive_service.dart';
import 'package:send_snap/UI/Components/category_selector.dart';
import 'package:send_snap/UI/Components/dashboard_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CategoryModel? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.expenses.listenable(),
        builder: (context, Box<ExpenseModel> box, _) {
          final allExpenses = box.values.toList().cast<ExpenseModel>();
          final filteredExpenses = selectedCategory == null
              ? allExpenses
              : allExpenses
                  .where((e) => e.category == selectedCategory!.name)
                  .toList();

          return Column(
            children: [
              // Dashboard Card - Non-scrollable
              DashboardCard(expenses: allExpenses),

              // Category Selector - Horizontal scroll (independent)
              CategorySelector(
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  debugPrint("Category changed to: ${category?.name ?? 'All'}");
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),

              const Divider(height: 1),

              // Expenses List - Vertical scroll
              Expanded(
                child: filteredExpenses.isEmpty
                    ? const Center(
                        child: Text(
                          "No expenses found",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 16, bottom: 80),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: ListTile(
                                leading: expense.imagepath.isNotEmpty &&
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
                                        backgroundColor: Colors.grey[200],
                                        child: Text(
                                          expense.category.isNotEmpty
                                              ? expense.category.substring(0, 1)
                                              : '?',
                                        ),
                                      ),
                                title: Text(
                                  expense.merchant,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  expense.date.toLocal().toString().split(' ')[0],
                                ),
                                trailing: Text(
                                  "${expense.currency} ${expense.total}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FAB pressed");
          // TODO: Add action for adding expense
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}