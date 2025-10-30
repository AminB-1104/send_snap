import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'dart:convert';
import 'dart:io';
import 'package:send_snap/Services/hive_service.dart';

class ExportDataPage extends StatefulWidget {
  const ExportDataPage({super.key});

  @override
  State<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends State<ExportDataPage> {
  String? selectedCategoriesText = 'All categories';
  String? selectedDateRange = 'Last month';
  String? selectedFormat = 'JSON';

  late Future<Box<CategoryModel>> _categoryBoxFuture;

  @override
  void initState() {
    super.initState();
    _categoryBoxFuture = _openBox();
  }

  Future<Box<CategoryModel>> _openBox() async {
    // if already open, just return it
    if (Hive.isBoxOpen('categories')) {
      return Hive.box<CategoryModel>('categories');
    }
    return await Hive.openBox<CategoryModel>('categories');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Box<CategoryModel>>(
      future: _categoryBoxFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final categoryBox = snapshot.data!;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: SvgPicture.asset(
                'assets/icons/arrow-left.svg',
                colorFilter: ColorFilter.mode(
                  theme.iconTheme.color!,
                  BlendMode.srcIn,
                ),
                width: 32,
                height: 32,
              ),
            ),
            title: Text(
              'Export Data',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                color: theme.textTheme.titleLarge!.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildOptionCard(
                  title: 'What data do you want to export?',
                  subtitle: selectedCategoriesText!,
                  onTap: () => _openCategorySelector(categoryBox),
                ),
                const SizedBox(height: 16),
                _buildOptionCard(
                  title: 'When date range?',
                  subtitle: selectedDateRange!,
                  onTap: _openDateRangeSelector,
                ),
                const SizedBox(height: 16),
                _buildOptionCard(
                  title: 'What format do you want to export?',
                  subtitle: selectedFormat!,
                  onTap: _openFormatSelector,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _exportData, // export functionality later
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff7F3DFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Export Data',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: theme.textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium!.color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 25,
              height: 25,
              child: SvgPicture.asset(
                'assets/icons/arrow-down-2.svg',
                colorFilter: ColorFilter.mode(
                  theme.iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Category Selector Modal ---
  void _openCategorySelector(Box<CategoryModel> categoryBox) async {
    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final categories = categoryBox.values.toList();

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
              SizedBox(
                height: 400,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Select Categories',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: theme.textTheme.bodyLarge!.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Color(
                                  0xFF2CFF05,
                                ).withValues(alpha: 0.15),
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/all-category.svg',
                                colorFilter: ColorFilter.mode(
                                  Colors.green,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            title: const Text(
                              'All Categories',
                              style: TextStyle(
                                color: Colors.green,
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              setState(
                                () => selectedCategoriesText = 'All categories',
                              );
                              Navigator.pop(context);
                            },
                          ),
                          for (final cat in categories)
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: cat.color.withValues(alpha: 0.15),
                                ),
                                child: SvgPicture.asset(
                                  cat.iconsvg,
                                  colorFilter: ColorFilter.mode(
                                    cat.color,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              title: Text(
                                cat.name,
                                style: TextStyle(
                                  color: cat.color,
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () {
                                setState(
                                  () => selectedCategoriesText = cat.name,
                                );
                                Navigator.pop(context);
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Date Range Selector Modal ---
  void _openDateRangeSelector() async {
    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
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
              Text(
                'Select Date Range',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 16),
              _dateOption('Today'),
              _dateOption('Last week'),
              _dateOption('Last 30 days'),
              _dateOption('Last year'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _dateOption(String label) {
    return ListTile(
      title: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xff7F3DFF),
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        setState(() => selectedDateRange = label);
        Navigator.pop(context);
      },
    );
  }

  // --- Format Selector Modal ---
  void _openFormatSelector() async {
    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
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
              Text(
                'Select Export Format',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 16),
              ListTile(
                title: const Text(
                  'JSON',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff7F3DFF),
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  setState(() => selectedFormat = 'JSON');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportData() async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Open the expense box
      final expenseBox = HiveService.expenses;
      final allExpenses = expenseBox.values.toList();

      // --- Filter by Category ---
      var filtered = allExpenses.where((expense) {
        if (selectedCategoriesText == 'All categories') return true;
        return expense.category == selectedCategoriesText;
      }).toList();

      // --- Filter by Date Range ---
      final now = DateTime.now();
      DateTime fromDate;

      switch (selectedDateRange) {
        case 'Today':
          fromDate = DateTime(now.day);
          break;
        case 'Last week':
          fromDate = now.subtract(const Duration(days: 7));
          break;
        case 'Last 30 days':
          fromDate = now.subtract(const Duration(days: 30));
          break;
        case 'Last year':
          fromDate = now.subtract(const Duration(days: 365));
          break;
        default:
          fromDate = DateTime(2000);
      }

      filtered = filtered.where((e) => e.date.isAfter(fromDate)).toList();

      if (filtered.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Expenses matches your filters!')),
        );
        return;
      }

      // --- Convert to JSON ---
      final jsonData = filtered
          .map(
            (e) => {
              'id': e.id,
              'merchant': e.merchant,
              'date': e.date.toIso8601String(),
              'total': e.total,
              'currency': e.currency,
              'category': e.category,
              'note': e.note,
              'imagepath': e.imagepath,
              'items': e.items,
            },
          )
          .toList();

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      print('Expense count: ${HiveService.expenses.length}');
      for (var e in HiveService.expenses.values) {
        print('Expense -> ${e.merchant} | ${e.total}');
      }

      // --- Save to Downloads Folder ---
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${downloadsDir.path}/expenses_export_$timestamp.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // --- Success Message ---
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Exported to Downloads!\n${filePath.split('/').last}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
