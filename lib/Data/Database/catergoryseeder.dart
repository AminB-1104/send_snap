import 'package:hive/hive.dart';
import '../Models/category_model.dart';

class CategorySeeder {
  static Future<void> seedCategories() async {
    final box = Hive.box<CategoryModel>('categories');


    if (box.isEmpty) {
      final predefinedCategories = [
        CategoryModel(id: 1, name: 'Food', iconsvg: '🍔'),
        CategoryModel(id: 2, name: 'Transport', iconsvg: '🚌'),
        CategoryModel(id: 3, name: 'Shopping', iconsvg: '🛍️'),
        CategoryModel(id: 4, name: 'Utilities', iconsvg: '💡'),
        CategoryModel(id: 5, name: 'Entertainment', iconsvg: '🎮'),
        CategoryModel(id: 6, name: 'Health', iconsvg: '💊'),
      ];

      await box.addAll(predefinedCategories);
      print('✅ Predefined categories seeded successfully');
    } else {
      print('⚡ Categories already exist — skipping seed.');
    }
  }
}
