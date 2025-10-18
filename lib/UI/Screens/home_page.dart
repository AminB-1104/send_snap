import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/Services/hive_service.dart';
import 'package:send_snap/UI/Components/appbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: ValueListenableBuilder(
        valueListenable: HiveService.expenses.listenable(),
        builder: (context, Box<ExpenseModel> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No expenses yet."));
          }

          final expenses = box.values.toList().cast<ExpenseModel>();

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  onTap: () => _showExpenseDetails(context, expense),
                  leading:
                      expense.imagepath.isNotEmpty &&
                          File(expense.imagepath).existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(expense.imagepath),
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            expense.category.isNotEmpty
                                ? expense.category.substring(0, 1)
                                : '?',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                  title: Text(
                    expense.merchant,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    expense.date.toLocal().toString().split(' ')[0],
                  ),
                  trailing: Text(
                    '${expense.currency} ${expense.total}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showMyDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _showExpenseDetails(BuildContext context, ExpenseModel expense) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (expense.imagepath.isNotEmpty &&
                      File(expense.imagepath).existsSync())
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(expense.imagepath),
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                  Text(
                    expense.merchant,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Category: ${expense.category}"),
                  Text(
                    "Date: ${expense.date.toLocal().toString().split(' ')[0]}",
                  ),
                  const SizedBox(height: 8),
                  if (expense.note.isNotEmpty) Text("Note: ${expense.note}"),
                  const SizedBox(height: 8),
                  if (expense.items.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Items:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        for (var item in expense.items) Text("• $item"),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ✅ EDIT BUTTON - opens inline modal
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // close detail modal first
                          _showEditExpenseModal(context, expense);
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Edit",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // ✅ DELETE BUTTON
                      ElevatedButton.icon(
                        onPressed: () async {
                          final box = HiveService.expenses;
                          final key = expense.key;

                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                'Are you sure you want to delete this expense?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await box.delete(key);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Expense deleted successfully'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showEditExpenseModal(BuildContext context, ExpenseModel expense) {
  final merchantController = TextEditingController(text: expense.merchant);
  final dateController = TextEditingController(
    text: expense.date.toLocal().toString().split(' ')[0],
  );
  final totalController = TextEditingController(text: expense.total.toString());
  final currencyController = TextEditingController(text: expense.currency);
  final noteController = TextEditingController(text: expense.note);

  final itemsController = TextEditingController(text: expense.items.join(', '));

  CategoryModel? selectedCategory;

  // Load all categories from Hive
  final categoryBox = HiveService.categories;
  final categories = categoryBox.values.toList();

  // Match the category by name
  selectedCategory = categories.firstWhere(
    (cat) => cat.name == expense.category,
    orElse: () => CategoryModel(id: 0, name: expense.category, iconsvg: '❓'),
  );

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Expense',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Merchant
                      TextField(
                        controller: merchantController,
                        decoration: const InputDecoration(
                          labelText: 'Merchant',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Date
                      TextField(
                        controller: dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: expense.date,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  dateController.text = picked
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0];
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Total
                      TextField(
                        controller: totalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Currency
                      TextField(
                        controller: currencyController,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Custom Category Picker (reused)
                      GestureDetector(
                        onTap: () async {
                          final selected =
                              await showModalBottomSheet<CategoryModel>(
                                context: context,
                                builder: (context) {
                                  return ListView(
                                    shrinkWrap: true,
                                    children: categories.map((cat) {
                                      return ListTile(
                                        leading: Text(
                                          cat.iconsvg,
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                        title: Text(cat.name),
                                        onTap: () =>
                                            Navigator.pop(context, cat),
                                      );
                                    }).toList(),
                                  );
                                },
                              );

                          if (selected != null) {
                            setState(() => selectedCategory = selected);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedCategory != null
                                ? '${selectedCategory!.iconsvg} ${selectedCategory!.name}'
                                : 'Select category',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Note
                      TextField(
                        controller: noteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Note',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Items (simple comma-separated)
                      TextField(
                        controller: itemsController,
                        decoration: const InputDecoration(
                          labelText: 'Items (comma separated)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Save Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final box = HiveService.expenses;

                            final updatedExpense = ExpenseModel(
                              id: expense.id,
                              merchant: merchantController.text.trim(),
                              date:
                                  DateTime.tryParse(dateController.text) ??
                                  DateTime.now(),
                              total: num.tryParse(totalController.text) ?? 0,
                              currency: currencyController.text.trim(),
                              category:
                                  selectedCategory?.name ?? expense.category,
                              note: noteController.text.trim(),
                              imagepath: expense.imagepath,
                              items: itemsController.text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList(),
                            );

                            await box.put(expense.key, updatedExpense);
                            Navigator.pop(context); // close modal
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Expense updated successfully!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Save Changes',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Close icon
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> _showMyDialog(BuildContext context) {
  return showDialog(
    context: context,
    useRootNavigator: true,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add an Expense'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => context.pushNamed('/imagegallery'),
            child: const Text('Pick From Gallery'),
          ),
          TextButton(
            onPressed: () => context.pushNamed('/imagecamera'),
            child: const Text('Take Photo'),
          ),
        ],
      );
    },
  );
}
