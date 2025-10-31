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
                Row(
                  children: [
                    const SizedBox(width: 15),
                    _NavItem(
                      index: 0,
                      assetPath: 'assets/icons/home.svg',
                      route: '/home',
                      label: 'Home',
                      isActive: currentIndex == 0,
                    ),
                    const SizedBox(width: 35),
                    _NavItem(
                      index: 1,
                      assetPath: 'assets/icons/transaction.svg',
                      route: '/transactions',
                      label: 'Transactions',
                      isActive: currentIndex == 1,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _NavItem(
                      index: 2,
                      assetPath: 'assets/icons/pie-chart.svg',
                      route: '/budget',
                      label: 'Budget',
                      isActive: currentIndex == 2,
                    ),
                    const SizedBox(width: 35),
                    _NavItem(
                      index: 3,
                      assetPath: 'assets/icons/user.svg',
                      route: '/profile',
                      label: 'Profile',
                      isActive: currentIndex == 3,
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
}

// Extracted widget to prevent rebuilds
class _NavItem extends StatelessWidget {
  final int index;
  final String assetPath;
  final String route;
  final String label;
  final bool isActive;

  const _NavItem({
    required this.index,
    required this.assetPath,
    required this.route,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            assetPath,
            width: isActive ? 30 : 28,
            height: isActive ? 30 : 28,
            colorFilter: ColorFilter.mode(
              isActive ? const Color(0xff7F3DFF) : const Color(0xffC6C6C6),
              BlendMode.srcIn,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xff7F3DFF) : const Color(0xffC6C6C6),
            ),
          ),
        ],
      ),
    );
  }
}