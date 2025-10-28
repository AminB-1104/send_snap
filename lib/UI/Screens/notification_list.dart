import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:send_snap/Services/notification_service.dart';

class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed('/notifSettings');
            },
            icon: SvgPicture.asset('assets/icons/settings.svg'),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: notificationService.notifications,
        builder: (context, notifications, _) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFF5F1FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF7F3DFF),
                  ),
                  title: Text(notifications[index]),
                  subtitle: Text(
                    "Just now",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
