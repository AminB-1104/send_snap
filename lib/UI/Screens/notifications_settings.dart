import 'package:flutter/material.dart';
import 'package:send_snap/Services/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);

      if (_isEnabled) {
        await _notificationService.cancelAll();
        await _notificationService.scheduleDailyNotification(picked);
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _isEnabled = value);
    if (value) {
      await _notificationService.scheduleDailyNotification(_selectedTime);
    } else {
      await _notificationService.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text(
                'Daily Expense Reminder',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Remind me to log my expenses daily'),
              value: _isEnabled,
              onChanged: _toggleNotifications,
              activeColor: const Color(0xFF7F3DFF),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.schedule_rounded,
                color: Color(0xFF7F3DFF),
              ),
              title: const Text('Reminder Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.edit_rounded),
              onTap: _isEnabled ? _pickTime : null,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _notificationService.showInstantNotification(
                    "Test reminder — you’re doing great!",
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Send Test Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F3DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
