// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/Services/hive_service.dart';
import 'package:send_snap/Services/receipt_scanner_service.dart';

class AddExpensePage extends StatefulWidget {
  final Function(CategoryModel?)? onChanged;
  const AddExpensePage({super.key, this.onChanged});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  bool _totalEmpty = false;
  bool _dateEmpty = false;
  bool _noteEmpty = false;
  bool _categoryEmpty = false;

  CategoryModel? selectedCategory;

  final List<TextEditingController> _itemControllers = [];

  final _merchantController = TextEditingController();
  final _dateController = TextEditingController();
  final _totalController = TextEditingController();
  final _currencyController = TextEditingController();
  final _noteController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  String? merchant;
  String? date;
  String? total;
  String? currency;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return;

    final image = File(pickedFile.path);
    setState(() => _image = image);

    try {
      final result = await ReceiptScannerService.scanReceipt(image);

      setState(() {
        merchant = result['merchant'];
        date = result['date'];
        total = result['total'];
        currency = result['currency'];

        _merchantController.text = merchant ?? '';
        _dateController.text = date ?? '';
        _totalController.text = total ?? '';
        _currencyController.text = currency ?? '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt scanned successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to scan receipt: $e')));
    }
  }

  void _addNewItem() {
    setState(() {
      _itemControllers.add(TextEditingController());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemControllers[index].dispose();
      _itemControllers.removeAt(index);
    });
  }

  void _saveExpense() {
    setState(() {
      _totalEmpty = _totalController.text.isEmpty;
      _dateEmpty = _dateController.text.isEmpty;
      _noteEmpty = _noteController.text.isEmpty;
      _categoryEmpty = selectedCategory == null;
    });

    if (_totalEmpty || _dateEmpty || _noteEmpty || _categoryEmpty) {
      // Optional: still show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Parse values
    final merchant = _merchantController.text;
    final dateParts = _dateController.text.split('/');
    final date = DateTime(
      int.parse(dateParts[2]),
      int.parse(dateParts[1]),
      int.parse(dateParts[0]),
    );
    final total = num.tryParse(_totalController.text) ?? 0;
    final currency = _currencyController.text;
    final category = selectedCategory!.name;
    final note = _noteController.text;

    final items = _itemControllers
        .map((c) => c.text)
        .where((e) => e.isNotEmpty)
        .toList();
    final imagepath = _image?.path ?? '';
    final id = DateTime.now().millisecondsSinceEpoch;

    final expense = ExpenseModel(
      id: id,
      merchant: merchant,
      date: date,
      total: total,
      currency: currency,
      category: category,
      note: note,
      imagepath: imagepath,
      items: items,
    );

    HiveService.expenses.add(expense);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _currencyController.text = 'USD'; // default currency
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _dateController.dispose();
    _totalController.dispose();
    _currencyController.dispose();
    _noteController.dispose();
    for (final c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // UI

  @override
  Widget build(BuildContext context) {
    final categoriesBox = HiveService.categories;
    final categories = categoriesBox.values.toList();
    final red = const Color(0xFFFD3C4A);

    return Scaffold(
      backgroundColor: red,
      body: SafeArea(
        child: Column(
          children: [
            // --- AppBar Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.asset(
                      'assets/icons/arrow-left.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const Text(
                    "Expense",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 40), // balance layout
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Amount Section ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 20),
                  child: Row(
                    children: [
                      Text(
                        "How much?",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      if (_totalEmpty)
                        const Text(
                          " *",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),

                // const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _totalController,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 64,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: _currencyController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- White Card Section ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _merchantController,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Merchant',
                          hintStyle: TextStyle(color: Color(0xAA91919F)),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Category field
                      GestureDetector(
                        onTap: () async {
                          final selected =
                              await showModalBottomSheet<CategoryModel>(
                                context: context,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  side: BorderSide.none,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (_) =>
                                    _CategoryPicker(categories: categories),
                              );

                          if (selected != null) {
                            setState(() => selectedCategory = selected);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: Color(0xff91919F)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (selectedCategory != null)
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      selectedCategory!.iconsvg,
                                      colorFilter: ColorFilter.mode(
                                        selectedCategory!.color,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      selectedCategory!.name,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        color: selectedCategory!.color,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                const Text(
                                  'Select category *',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xAA91919F),
                                  ),
                                ),
                              SvgPicture.asset('assets/icons/arrow-down-2.svg'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Date field
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: _dateEmpty
                              ? 'Select a date *'
                              : 'Select a date',
                          hintStyle: TextStyle(color: Color(0xAA91919F)),
                          suffixIcon: Icon(Icons.calendar_month_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1990),
                            lastDate: DateTime(2050),
                          );

                          if (pickedDate != null) {
                            _dateController.text =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            setState(
                              () => _dateEmpty = false,
                            ); // remove red asterisk once filled
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      // Note field
                      TextFormField(
                        controller: _noteController,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintText: _noteEmpty
                              ? 'Description *'
                              : 'Description',
                          hintStyle: TextStyle(color: Color(0xAA91919F)),
                        ),
                        onChanged: (_) {
                          if (_noteEmpty) setState(() => _noteEmpty = false);
                        },
                      ),

                      const SizedBox(height: 12),

                      // Items Section
                      Text(
                        "Items (optional)",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Column(
                        children: List.generate(_itemControllers.length, (
                          index,
                        ) {
                          final controller = _itemControllers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: controller,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Item name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      fillColor: Colors.grey.shade100,
                                      filled: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _removeItem(index),
                                  child: SvgPicture.asset(
                                    'assets/icons/trash.svg',
                                    colorFilter: ColorFilter.mode(
                                      Colors.red,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      // Add Item button
                      TextButton.icon(
                        onPressed: _addNewItem,
                        icon: Icon(Icons.add, color: Color(0xFF7F3DFF)),
                        label: Text(
                          "Add Item",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7F3DFF),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Add Attachment field
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey.shade100,
                        ),
                        child: Material(
                          color: Colors.white,
                          child: InkWell(
                            onTap: () {
                              _showAttachmentModal(context);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/attachment.svg',
                                  width: 32,
                                  height: 32,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xAA91919F),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Add attachment",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xAA91919F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      //Image Showcase
                      if (_image != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Image.file(
                                  _image!,
                                  width: double.infinity,
                                  fit: BoxFit
                                      .fitWidth, // will stretch the width, keep aspect ratio
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _image = null;
                                        _merchantController.clear();
                                        _dateController.clear();
                                        _totalController.clear();
                                        _currencyController.clear();
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SizedBox(
            height: 56, // button height
            child: ElevatedButton(
              onPressed: () {
                _saveExpense();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Color(0xFF7F3DFF),
              ),
              child: const Text(
                "Add Expense",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ATTACHMENT POP-UP MODAL
  void _showAttachmentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Color(0xAAD3BDFF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Card(
                      color: Color(0xAAEEE5FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(15),
                        side: BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 50,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/camera.svg',
                              colorFilter: ColorFilter.mode(
                                Color(0xFF7F3DFF),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Camera',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff7F3DFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Card(
                      color: Color(0xAAEEE5FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(15),
                        side: BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 55,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/gallery.svg',
                              colorFilter: ColorFilter.mode(
                                Color(0xFF7F3DFF),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Image',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff7F3DFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

// CATEGORY PICKER POP-UP MODAL
class _CategoryPicker extends StatelessWidget {
  final List<CategoryModel> categories;

  const _CategoryPicker({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
          const Text(
            'Select Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 60),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () => Navigator.pop(context, cat),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        cat.iconsvg,
                        colorFilter: ColorFilter.mode(
                          cat.color,
                          BlendMode.srcIn,
                        ),
                      ),

                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: cat.color,
                        ),

                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
