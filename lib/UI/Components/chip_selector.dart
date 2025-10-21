import 'package:flutter/material.dart';

class FilterSelector extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['Today', 'Week', 'Month', 'Year'];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            selectedColor: const Color(0xAA7F3DFF),
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => onFilterChanged(filter),
          );
        },
      ),
    );
  }
}
