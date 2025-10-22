// lib/UI/Components/appbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? profileImage;
  final int selectedMonth;
  final ValueChanged<int> onMonthChanged;

  const HomeAppBar({
    super.key,
    this.profileImage,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _HomeAppBarState extends State<HomeAppBar> {
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
    final purple = const Color(0xFF7F3DFF);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () {},
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: widget.profileImage != null
                ? AssetImage(widget.profileImage!)
                : null,
            child: widget.profileImage == null
                ? Icon(Icons.person, color: purple)
                : null,
          ),
        ),
      ),

      // === TITLE: Keep your original layout (SVG arrow then month text) ===
      title: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: widget.selectedMonth, // use parent's selectedMonth
          items: List.generate(12, (i) {
            final m = i + 1;
            return DropdownMenuItem(
              value: m,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  months[i],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: m == widget.selectedMonth
                        ? const Color(0xFF7F3DFF)
                        : Colors.black,
                  ),
                ),
              ),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              // pass selection up to parent
              widget.onMonthChanged(value);
            }
          },

          icon: const SizedBox.shrink(),

          selectedItemBuilder: (context) => List.generate(12, (i) {
            // keep the original arrow+text layout
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/arrow-down-2.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF7F3DFF),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  months[i],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }),

          dropdownColor: Colors.white,
          isDense: true,
          alignment: Alignment.center,
        ),
      ),

      // Notifications (only SVG button, same color)
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/notification.svg',
              colorFilter: const ColorFilter.mode(
                Color(0xFF7F3DFF),
                BlendMode.srcIn,
              ),
              width: 34,
              height: 34,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
