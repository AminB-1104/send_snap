import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/Services/hive_service.dart';

class ImportDataPage extends StatefulWidget {
  const ImportDataPage({super.key});

  @override
  State<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage> {
  String? _selectedFilePath;
  int _importedCount = 0;
  int _skippedCount = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'Import Data',
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

            // --- Select File Card ---
            _buildOptionCard(
              title: 'Select File to Import',
              subtitle: _selectedFilePath == null
                  ? 'No file selected'
                  : _selectedFilePath!.split('/').last,
              onTap: _pickFile,
            ),
            const Spacer(),

            // --- Import Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedFilePath == null ? null : _importData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Import Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            if (_importedCount > 0 || _skippedCount > 0)
              Center(
                child: Text(
                  'Imported $_importedCount, Skipped $_skippedCount',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Inter',
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
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
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
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

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _selectedFilePath = result.files.single.path!;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File selection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importData() async {
    try {
      final file = File(_selectedFilePath!);
      final jsonString = await file.readAsString();
      final List<dynamic> decoded = jsonDecode(jsonString);

      if (decoded.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected file is empty.')),
        );
        return;
      }

      final expenseBox = HiveService.expenses;
      int imported = 0;
      int skipped = 0;

      for (var e in decoded) {
        final id = e['id'];
        if (expenseBox.containsKey(id)) {
          skipped++;
          continue; // Skip duplicates (smart import)
        }

        final expense = ExpenseModel(
          id: DateTime.now().millisecondsSinceEpoch,
          merchant: e['merchant'] ?? '',
          date: DateTime.parse(e['date']),
          total: (e['total'] ?? 0).toDouble(),
          currency: e['currency'] ?? '',
          category: e['category'] ?? '',
          note: e['note'] ?? '',
          imagepath: e['imagepath'] ?? '',
          items: List<String>.from(e['items'] ?? []),
        );

        await expenseBox.add(expense);
        imported++;
      }

      setState(() {
        _importedCount = imported;
        _skippedCount = skipped;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported: $imported | Skipped: $skipped'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
