import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            width: 32,
            height: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // _buildSettingTile(context, 'Language', 'English', '/language'),
          _buildSettingTile(context, 'Theme', '/themeSettings'),
          _buildSettingTile(context, 'Notification', '/notifSettings'),
          // const Divider(height: 32),
          // _buildSettingTile(context, 'About', '', '/about'),
          // _buildSettingTile(context, 'Help', '', '/help'),
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, String title, String path) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 10),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      trailing: SvgPicture.asset(
        'assets/icons/arrow-right-2.svg',
        width: 25,
        height: 25,
        colorFilter: const ColorFilter.mode(
          Color(0xFF7B61FF), // purple accent
          BlendMode.srcIn,
        ),
      ),
      onTap: () {
        context.pushNamed(path);
      },
    );
  }
}
