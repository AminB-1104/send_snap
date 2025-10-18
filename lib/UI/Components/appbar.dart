import 'package:flutter/material.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? profileImage;
  final int notificationCount;
  final ValueChanged<String> onMonthChanged;

  const HomeAppBar({
    super.key,
    this.profileImage,
    required this.notificationCount,
    required this.onMonthChanged,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _HomeAppBarState extends State<HomeAppBar> {
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  late String selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = _months[DateTime.now().month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final purple = const Color(0xFF7F3DFF);

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile (leading)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () {
                // TODO: navigate to profile
              },
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

          // Month selector (center) — implemented as PopupMenuButton for reliability
          PopupMenuButton<String>(
            initialValue: selectedMonth,
            tooltip: 'Select month',
            offset: const Offset(0, 48),
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            onSelected: (value) {
              setState(() => selectedMonth = value);
              widget.onMonthChanged(value);
            },
            itemBuilder: (context) {
              return _months.map((m) {
                return PopupMenuItem<String>(
                  value: m,
                  child: Text(m,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      )),
                );
              }).toList();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedMonth,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),

          // Notifications (trailing)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    size: 26,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    // TODO: open notifications page
                  },
                ),
                if (widget.notificationCount > 0)
                  Positioned(
                    right: 6,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: purple,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        widget.notificationCount > 99 ? '99+' : widget.notificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
