import 'package:flutter/material.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'package:send_snap/Services/hive_service.dart';

class CategorySelector extends StatelessWidget {
  final CategoryModel? selectedCategory;
  final ValueChanged<CategoryModel?> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = HiveService.categories.values.toList();

    return SizedBox(
      height: 60, // fixed height for the chip row
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" chip
            return ChoiceChip(
              label: const Text("All"),
              selected: selectedCategory == null,
              selectedColor: Colors.blueAccent,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: selectedCategory == null ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => onCategorySelected(null),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategory?.id == category.id;

          return ChoiceChip(
            label: Text("${category.iconsvg} ${category.name}"),
            selected: isSelected,
            selectedColor: const Color(0xAA7F3DFF),
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => onCategorySelected(category),
          );
        },
      ),
    );
  }
}
