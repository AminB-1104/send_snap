// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:send_snap/UI/Components/appbar.dart';

// class ImagePickerGallery extends StatefulWidget {
//   const ImagePickerGallery({super.key});

//   @override
//   State<ImagePickerGallery> createState() => _ImagePickerGalleryState();
// }

// class _ImagePickerGalleryState extends State<ImagePickerGallery> {
//   @override
//   void initState() {
//     super.initState();
//     pickImage();
//   }

//   File? _image;

//   final _picker = ImagePicker();

//   pickImage() async {
//     final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

//     if (pickedImage != null) {
//       _image = File(pickedImage.path);
//       setState(() {});
//     } else {
//       return AlertDialog(content: Center(child: Text("Error loading image!")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(),
//       body: Center(
//         child: _image == null
//             ? const Text("No Image Picked!", style: TextStyle(fontSize: 25))
//             : Image.file(_image!),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:send_snap/UI/Components/appbar.dart';

class ImagePickerGallery extends StatefulWidget {
  const ImagePickerGallery({super.key});

  @override
  State<ImagePickerGallery> createState() => _ImagePickerGalleryState();
}

class _ImagePickerGalleryState extends State<ImagePickerGallery> {
  File? _image;
  bool _processing = false;

  // Controllers for editable fields
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
    pickImage();
  }

  Future<void> pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
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

      // Guess details
      final merchant = _guessMerchant(lines) ?? '';
      final date = _guessDate(lines);
      final total = extractTotal(recognizedText.text) ?? ''; // ✅ fixed
      final currency = _guessCurrency(lines); // ✅ added

      // Fill controllers
      _merchantController.text = merchant;
      _dateController.text = date != null ? date.toString().split(' ')[0] : '';
      _totalController.text = total;
      _currencyController.text = currency;
      _noteController.text = "Note something about this purchase here";

      // Clear previous controllers before creating new ones
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
      // 15/10/2025 or 15-10-2025 or 15.10.2025
      RegExp(r'(\d{1,2}[\/\-\.\s]\d{1,2}[\/\-\.\s]\d{2,4})'),
      // 2025-10-15 or 2025/10/15
      RegExp(r'(\d{4}[\/\-\.\s]\d{1,2}[\/\-\.\s]\d{1,2})'),
      // OCT 15 2025 or 17 OCT 25
      RegExp(r'(\d{1,2}\s+[A-Z]{3,9}\s+\d{2,4})'),
      // October 15, 2025
      RegExp(r'([A-Z][a-z]{2,8}\s+\d{1,2},?\s+\d{2,4})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        var raw = match.group(0)!.replaceAll(',', '').trim();

        try {
          // Numeric formats
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

          // ISO format
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

          // Month names or abbreviations
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

    // Default to USD if nothing matched
    return 'USD';
  }

  String? extractTotal(String text) {
    final lower = text.toLowerCase();

    // Split into lines and remove irrelevant ones
    final lines = lower.split('\n').where((line) {
      return !(line.contains('account') ||
          line.contains('approval') ||
          line.contains('card') ||
          line.contains('ref') ||
          line.contains('terminal'));
    }).toList();

    // Try finding a "total" keyword followed by a number (even across multiple spaces/dots)
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

    // If still not found, look for a standalone large number (as fallback)
    final numberPattern = RegExp(r'([\d]{1,3}(?:[.,]\d{3})*(?:[.,]\d{2}))');
    for (final line in lines.reversed) {
      if (line.contains('total')) continue; // skip already handled
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
    return Scaffold(
      appBar: const CustomAppBar(),
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
                  _buildTextField(
                    "Total",
                    _totalController,
                    keyboard: TextInputType.number,
                  ),
                  _buildTextField("Currency", _currencyController),
                  _buildTextField("Note", _noteController),

                  // 🧾 Items section (editable + manual add)
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

                  // ➕ Add Item button (always visible)
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
                    onPressed: () {
                      setState(() {
                        _itemControllers.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Item"),
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
}
