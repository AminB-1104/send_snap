import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MonthDropdown extends StatefulWidget {
  final int selectedMonth;
  final ValueChanged<int> onMonthChanged;

  const MonthDropdown({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  State<MonthDropdown> createState() => _MonthDropdownState();
}

class _MonthDropdownState extends State<MonthDropdown> {
  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: widget.selectedMonth,
        items: List.generate(12, (i) {
          final m = i + 1;
          return DropdownMenuItem(
            value: m,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                months[i],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: m == widget.selectedMonth
                      ? const Color(0xFF7F3DFF)
                      : theme.textTheme.titleLarge!.color,
                ),
              ),
            ),
          );
        }),
        onChanged: (value) {
          if (value != null) {
            widget.onMonthChanged(value);
          }
        },
        icon: const SizedBox.shrink(),
        selectedItemBuilder: (context) => List.generate(12, (i) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/arrow-down-2.svg',
                width: 25,
                height: 25,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF7F3DFF),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                months[i],
                style: TextStyle(
                  color: theme.textTheme.titleLarge!.color,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }),
        dropdownColor: theme.colorScheme.surface,
        isDense: true,
        borderRadius: BorderRadius.circular(16),
        alignment: Alignment.center,
      ),
    );
  }
}
