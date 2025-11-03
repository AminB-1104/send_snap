import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptScannerService {
  // Run in isolate to prevent UI freeze
  static Future<Map<String, dynamic>> scanReceipt(File image) async {
    try {
      // Run the heavy ML processing in a separate isolate (background thread)
      final result = await _scanInBackground(image.path);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // This runs in background isolate - won't block UI
  static Future<Map<String, dynamic>> _scanInBackground(
    String imagePath,
  ) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      final lines = _extractLines(recognizedText);

      return {
        'merchant': _guessMerchant(lines) ?? '',
        'date': _guessDate(lines)?.toString().split(' ')[0] ?? '',
        'total': _extractTotal(recognizedText.text) ?? '',
        'currency': _guessCurrency(lines),
      };
    } catch (e) {
      rethrow;
    } finally {
      textRecognizer.close();
    }
  }

  static List<String> _extractLines(RecognizedText text) {
    final lines = <String>[];
    for (final block in text.blocks) {
      for (final line in block.lines) {
        final clean = line.text.trim();
        if (clean.isNotEmpty) lines.add(clean);
      }
    }
    return lines;
  }

  static String? _guessMerchant(List<String> lines) {
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

  static DateTime? _guessDate(List<String> lines) {
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
        final raw = match.group(0)!.replaceAll(',', '').trim();
        try {
          if (RegExp(
            r'^\d{1,2}[\/\-\.\s]\d{1,2}[\/\-\.\s]\d{2,4}$',
          ).hasMatch(raw)) {
            final parts = raw.split(RegExp(r'[\/\-\.\s]'));
            return DateTime(
              int.parse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (_) {}
      }
    }
    return null;
  }

  static String _guessCurrency(List<String> lines) {
    final text = lines.join(' ').toUpperCase();
    if (text.contains('USD') || text.contains('\$')) return 'USD';
    if (text.contains('EUR') || text.contains('€')) return 'EUR';
    if (text.contains('GBP') || text.contains('£')) return 'GBP';
    if (text.contains('PKR') || RegExp(r'\bRS\b').hasMatch(text)) return 'PKR';
    return 'USD';
  }

  static String? _extractTotal(String text) {
    final lower = text.toLowerCase();
    final lines = lower.split('\n');

    final totalKeywords = ['total', 'amount due', 'balance', 'grand total'];

    final blacklist = [
      'change',
      'tax',
      'subtotal',
      'account',
      'item',
      'invoice',
      'total tax',
      'change due',
      'debit tend',
      'cash tend',
      'account #',
      '        ',
      '       ',
      '      ',
      '     ',
      '    ',
      '   ',
      '  ',
      ' ',
      '********',
      '*******',
      '******',
      '*****',
      '****',
      '***',
      '**',
      '*',
    ];

    for (final line in lines) {
      if (blacklist.any((b) => line.contains(b))) continue;

      if (totalKeywords.any((k) => line.contains(k))) {
        final matches = RegExp(r'([\d.,]+)').allMatches(line);
        for (final match in matches.toList().reversed) {
          final value = match.group(1)?.replaceAll(RegExp(r'[^0-9.]'), '');
          if (value != null &&
              value.isNotEmpty &&
              double.tryParse(value) != null) {
            return value;
          }
        }
      }
    }

    for (final line in lines.reversed) {
      if (blacklist.any((b) => line.contains(b))) continue;

      final matches = RegExp(r'([\d.,]+)').allMatches(line);
      for (final match in matches.toList().reversed) {
        final value = match.group(1)?.replaceAll(RegExp(r'[^0-9.]'), '');
        if (value != null &&
            value.isNotEmpty &&
            double.tryParse(value) != null) {
          return value;
        }
      }
    }

    return null;
  }
}
