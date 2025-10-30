import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 10,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side
                Row(
                  children: [
                    const SizedBox(width: 15),
                    _buildNavItem(
                      context,
                      0,
                      'assets/icons/home.svg',
                      '/home',
                      'Home',
                    ),
                    const SizedBox(width: 35),
                    _buildNavItem(
                      context,
                      1,
                      'assets/icons/transaction.svg',
                      '/transactions',
                      'Transactions',
                    ),
                  ],
                ),

                // Invisible spacer to balance FAB
                // const SizedBox(width: 60), // same width as FAB’s diameter
                // Right side
                Row(
                  children: [
                    _buildNavItem(
                      context,
                      2,
                      'assets/icons/pie-chart.svg',
                      '/budget',
                      'Budget',
                    ),
                    const SizedBox(width: 35),
                    _buildNavItem(
                      context,
                      3,
                      'assets/icons/user.svg',
                      '/profile',
                      'Profile',
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String assetPath,
    String route,
    String label,
  ) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => context.pushNamed(route),
      child: Column(
        children: [
          SvgPicture.asset(
            assetPath,
            width: isActive ? 30 : 28,
            height: isActive ? 30 : 28,
            colorFilter: ColorFilter.mode(
              isActive ? Color(0xff7F3DFF) : Color(0xffC6C6C6),
              BlendMode.srcIn,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? Color(0xff7F3DFF) : Color(0xffC6C6C6),
            ),
          ),
        ],
      ),
    );
  }
}
