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
    final theme = Theme.of(context);

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          return Center(
            child: ChoiceChip(
              label: Text(filter),
              backgroundColor: theme.colorScheme.surface,
              selected: isSelected,
              selectedColor: const Color(0xffFCEED4),
              // backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Color(0xffFCAC12) : Color(0xff91919F),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              showCheckmark: false,
              elevation: 0,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
              onSelected: (_) => onFilterChanged(filter),
            ),
          );
        },
      ),
    );
  }
}
