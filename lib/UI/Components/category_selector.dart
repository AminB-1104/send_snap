import 'package:flutter/material.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'package:send_snap/Services/hive_service.dart';

class CategorySelector extends StatefulWidget {
  final CategoryModel? selectedCategory;
  final ValueChanged<CategoryModel?> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = HiveService.categories.values.toList();

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const ClampingScrollPhysics(),
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildChip(
              label: "All",
              isSelected: widget.selectedCategory == null,
              onTap: () {
                debugPrint("All chip tapped");
                widget.onCategorySelected(null);
              },
            );
          }

          final category = categories[index - 1];
          final isSelected = widget.selectedCategory?.id == category.id;

          return _buildChip(
            label: "${category.iconsvg} ${category.name}",
            isSelected: isSelected,
            onTap: () {
              debugPrint("Category ${category.name} tapped");
              widget.onCategorySelected(category);
            },
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.grey[400]!,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}