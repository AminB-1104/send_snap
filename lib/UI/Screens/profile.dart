import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:send_snap/UI/Components/bottombar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF7F3DFF);
    final greyText = Colors.grey[600];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // Profile avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor: purple.withValues(alpha: 0.1),
                  backgroundImage: const AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(height: 12),

                // name
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),

                //email
                Text(
                  'johndoe@example.com',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: greyText,
                  ),
                ),
                const SizedBox(height: 32),

                // buttons
                const SizedBox(height: 20),
                _buildListTile(
                  icon: 'assets/icons/settings.svg',
                  label: 'Settings',
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                _buildListTile(
                  icon: 'assets/icons/notification.svg',
                  label: 'Notifications',
                  onTap: () {},
                ),

                const SizedBox(height: 20),
                _buildListTile(
                  icon: 'assets/icons/upload.svg',
                  label: 'Export Data',
                  onTap: () {
                    context.pushNamed('/export');
                  },
                ),
                const SizedBox(height: 20),
                _buildListTile(
                  icon: 'assets/icons/logout.svg',
                  label: 'Log Out',
                  onTap: () {},
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF7F3DFF),
          elevation: 0,
          shape: const CircleBorder(),
          onPressed: () {
            context.pushNamed('/addExpense');
          },
          child: Transform.rotate(
            angle: 25 * math.pi / 100,
            child: SvgPicture.asset(
              width: 40,
              height: 40,
              'assets/icons/close.svg',
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildListTile({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Color(0xffEEE5FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF7F3DFF),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
