import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/notification_service.dart';
import '../../services/user_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _userService = UserService();
  final _notificationService = NotificationService();
  bool _notificationsEnabled = true;
  bool _isSaving = false;
  List<String> _reminderTimes = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    final times = await _notificationService.getReminderTimes();

    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _reminderTimes = times;
    });
  }

  Future<void> _setNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
      _isSaving = true;
    });

    try {
      await _userService.updateSettings(notificationsEnabled: value);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', value);
      await _notificationService.setEnabled(value);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _addReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select study reminder time',
    );
    if (picked == null || !mounted) return;

    final timeStr =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    if (_reminderTimes.contains(timeStr)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This reminder time already exists.')),
      );
      return;
    }

    await _notificationService.addReminderTime(timeStr);
    final times = await _notificationService.getReminderTimes();
    if (!mounted) return;
    setState(() {
      _reminderTimes = times;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set at ${_formatTime(picked)}')),
    );
  }

  Future<void> _removeReminderTime(String time) async {
    await _notificationService.removeReminderTime(time);
    final times = await _notificationService.getReminderTimes();
    if (!mounted) return;
    setState(() {
      _reminderTimes = times;
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  String _timeLabel(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return timeStr;
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // --- Enable / Disable ---
          Card(
            child: SwitchListTile(
              value: _notificationsEnabled,
              onChanged: _isSaving ? null : _setNotifications,
              title: const Text('Study reminders'),
              subtitle: const Text('Get notified when it\'s time to study.'),
              secondary: Icon(
                _notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: _notificationsEnabled ? theme.colorScheme.primary : null,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- Reminder Times ---
          if (_notificationsEnabled) ...[
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reminder Times',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_reminderTimes.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.alarm_add,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No reminders yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap the button below to add a study reminder.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_reminderTimes.length, (index) {
                final time = _reminderTimes[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.notifications_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      _timeLabel(time),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('Daily reminder'),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () => _removeReminderTime(time),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addReminderTime,
                icon: const Icon(Icons.add),
                label: const Text('Add Reminder Time'),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: Icon(Icons.info_outline, color: theme.colorScheme.outline),
            title: Text(
              'About reminders',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Reminders will appear as push notifications at your selected times each day. '
              'You can add multiple reminder times to match your study schedule.',
            ),
          ),
        ],
      ),
    );
  }
}
