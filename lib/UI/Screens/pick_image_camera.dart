// ignore_for_file: use_build_context_synchronously

import 'package:hive/hive.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/Data/Models/item_model.dart';
import 'package:send_snap/Services/hive_service.dart';
import '../../Data/Models/category_model.dart';

class ImagePickerCamera extends StatefulWidget {
  const ImagePickerCamera({super.key});

  @override
  State<ImagePickerCamera> createState() => _ImagePickerCameraState();
}

class _ImagePickerCameraState extends State<ImagePickerCamera> {
  File? _image;
  bool _processing = false;

  CategoryModel? _selectedCategory; // ✅ fixed type
  late Box<CategoryModel> _categoryBox;

  // Controllers
  final _merchantController = TextEditingController();
  final _dateController = TextEditingController();
  final _totalController = TextEditingController();
  final _currencyController = TextEditingController();
  final _noteController = TextEditingController();
  final List<TextEditingController> _itemControllers = [];

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _categoryBox = HiveService.categories;
    pickImage();
  }

  Future<void> pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;

    setState(() {
      _image = File(pickedImage.path);
      _processing = true;
    });

    await _readReceiptText(_image!);
  }

  Future<void> _readReceiptText(File image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      final lines = _extractLines(recognizedText);

      final merchant = _guessMerchant(lines) ?? '';
      final date = _guessDate(lines);
      final total = extractTotal(recognizedText.text) ?? '';
      final currency = _guessCurrency(lines);

      _merchantController.text = merchant;
      _dateController.text = date != null ? date.toString().split(' ')[0] : '';
      _totalController.text = total;
      _currencyController.text = currency;
      _noteController.text = "Note something about this purchase here";

      _itemControllers.clear();

      setState(() {
        _processing = false;
      });
    } catch (e) {
      debugPrint("Error reading receipt: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _processing = false);
    } finally {
      textRecognizer.close();
    }
  }

  // --- Helpers ---
  List<String> _extractLines(RecognizedText text) {
    final lines = <String>[];
    for (final block in text.blocks) {
      for (final line in block.lines) {
        final clean = line.text.trim();
        if (clean.isNotEmpty) lines.add(clean);
      }
    }
    return lines;
  }

  String? _guessMerchant(List<String> lines) {
    final blacklist = RegExp(
      r'(receipt|tax|invoice|total|amount)',
      caseSensitive: false,
    );
    for (final line in lines) {
      if (!blacklist.hasMatch(line) &&
          line.length > 2 &&
          line.split(' ').length <= 4) {
        return line;
      }
    }
    return null;
  }

  DateTime? _guessDate(List<String> lines) {
    final text = lines.join(' ').toUpperCase();

    final patterns = [
      RegExp(r'(\d{1,2}[\/\-\.\s]\d{1,2}[\/\-\.\s]\d{2,4})'),
      RegExp(r'(\d{4}[\/\-\.\s]\d{1,2}[\/\-\.\s]\d{1,2})'),
      RegExp(r'(\d{1,2}\s+[A-Z]{3,9}\s+\d{2,4})'),
      RegExp(r'([A-Z][a-z]{2,8}\s+\d{1,2},?\s+\d{2,4})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        var raw = match.group(0)!.replaceAll(',', '').trim();

        try {
          if (RegExp(
            r'^\d{1,2}[\/\-\.\s]\d{1,2}[\/\-\.\s]\d{2,4}$',
          ).hasMatch(raw)) {
            final parts = raw.split(RegExp(r'[\/\-\.\s]'));
            final d = int.parse(parts[0]);
            final m = int.parse(parts[1]);
            final y = int.parse(
              parts[2].length == 2 ? '20${parts[2]}' : parts[2],
            );
            return DateTime(y, m, d);
          }

          if (RegExp(
            r'^\d{4}[\/\-\.\s]\d{1,2}[\/\-\.\s]\d{1,2}$',
          ).hasMatch(raw)) {
            final parts = raw.split(RegExp(r'[\/\-\.\s]'));
            return DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }

          final months = {
            'JAN': 1,
            'FEB': 2,
            'MAR': 3,
            'APR': 4,
            'MAY': 5,
            'JUN': 6,
            'JUL': 7,
            'AUG': 8,
            'SEP': 9,
            'OCT': 10,
            'NOV': 11,
            'DEC': 12,
          };

          final parts = raw.split(RegExp(r'\s+'));
          if (parts.length >= 3) {
            final d = int.tryParse(parts[0]) ?? 1;
            final m = months[parts[1].substring(0, 3).toUpperCase()] ?? 1;
            var y = int.tryParse(parts[2]) ?? DateTime.now().year;
            if (y < 100) y += 2000;
            return DateTime(y, m, d);
          }
        } catch (_) {
          continue;
        }
      }
    }
    return null;
  }

  String _guessCurrency(List<String> lines) {
    final text = lines.join(' ').toUpperCase();

    if (text.contains('USD') || text.contains('\$')) return 'USD';
    if (text.contains('EUR') || text.contains('€')) return 'EUR';
    if (text.contains('GBP') || text.contains('£')) return 'GBP';
    if (text.contains('PKR') || RegExp(r'\bRS\b').hasMatch(text)) return 'PKR';

    return 'USD';
  }

  String? extractTotal(String text) {
    final lower = text.toLowerCase();
    final lines = lower.split('\n').where((line) {
      return !(line.contains('account') ||
          line.contains('approval') ||
          line.contains('card') ||
          line.contains('ref') ||
          line.contains('terminal'));
    }).toList();

    final totalPattern = RegExp(
      r'(total|amount\s*due|balance)[^\d]{0,10}([\d.,]+)',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = totalPattern.firstMatch(line);
      if (match != null) {
        final value = match.group(2);
        if (value != null) {
          final parsed = double.tryParse(
            value.replaceAll(RegExp(r'[^0-9.]'), ''),
          );
          if (parsed != null && parsed > 0 && parsed < 100000) {
            return parsed.toString();
          }
        }
      }
    }

    final numberPattern = RegExp(r'([\d]{1,3}(?:[.,]\d{3})*(?:[.,]\d{2}))');
    for (final line in lines.reversed) {
      if (line.contains('total')) continue;
      final match = numberPattern.firstMatch(line);
      if (match != null) {
        final value = match.group(1);
        if (value != null) {
          final parsed = double.tryParse(
            value.replaceAll(RegExp(r'[^0-9.]'), ''),
          );
          if (parsed != null && parsed > 0 && parsed < 100000) {
            return parsed.toString();
          }
        }
      }
    }
    return null;
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    final categories = _categoryBox.values.toList();
    return Scaffold(
     
      body: _processing
          ? const Center(child: CircularProgressIndicator())
          : _image == null
          ? const Center(child: Text("No image selected"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Image.file(_image!),
                  const SizedBox(height: 20),
                  _buildTextField("Merchant", _merchantController),
                  _buildTextField("Date", _dateController),
                  const SizedBox(height: 10),

                  // ✅ Category Selector (Bottom Sheet)
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
                                    onTap: () => Navigator.pop(context, cat),
                                  );
                                }).toList(),
                              );
                            },
                          );

                      if (selected != null) {
                        setState(() => _selectedCategory = selected);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedCategory != null
                            ? '${_selectedCategory!.iconsvg} ${_selectedCategory!.name}'
                            : 'Select category',
                      ),
                    ),
                  ),

                  _buildTextField(
                    "Total",
                    _totalController,
                    keyboard: TextInputType.number,
                  ),
                  _buildTextField("Currency", _currencyController),
                  _buildTextField("Note", _noteController),

                  if (_itemControllers.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      "Items",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      itemCount: _itemControllers.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _itemControllers[index],
                                  decoration: InputDecoration(
                                    labelText: "Item ${index + 1}",
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _itemControllers.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _itemControllers.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Item"),
                    ),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _saveExpense,
                    icon: const Icon(Icons.save),
                    label: const Text("Save Expense"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text("Scan another receipt"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    final expenseBox = HiveService.expenses;
    final itemsBox = HiveService.items;

    final List<String> itemNames = [];

    for (var controller in _itemControllers) {
      final itemName = controller.text.trim();
      if (itemName.isEmpty) continue;

      final newItem = ItemsModel(name: itemName, quantity: 1, unitprice: 0);
      await itemsBox.add(newItem);
      itemNames.add(itemName);
    }

    final newExpense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch,
      merchant: _merchantController.text.trim(),
      date: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      total: num.tryParse(_totalController.text) ?? 0,
      currency: _currencyController.text.trim(),
      category: _selectedCategory?.name ?? 'Uncategorized',
      note: _noteController.text.trim(),
      imagepath: _image?.path ?? '',
      items: itemNames,
    );

    await expenseBox.add(newExpense);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense saved successfully!')),
    );

    setState(() {
      _merchantController.clear();
      _dateController.clear();
      _totalController.clear();
      _currencyController.clear();
      _noteController.clear();
      _itemControllers.clear();
      _selectedCategory = null;
      _image = null;
    });
  }
}
