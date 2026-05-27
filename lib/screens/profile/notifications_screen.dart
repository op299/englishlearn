import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/user_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _userService = UserService();
  bool _notificationsEnabled = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadLocalSetting();
  }

  Future<void> _loadLocalSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? _notificationsEnabled;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: _notificationsEnabled,
            onChanged: _isSaving ? null : _setNotifications,
            title: const Text('Learning reminders'),
            subtitle: const Text('Receive daily practice and review reminders.'),
            secondary: const Icon(Icons.notifications_outlined),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Review reminders'),
            subtitle: Text(
              _notificationsEnabled
                  ? 'Notifications are enabled for this account.'
                  : 'Notifications are disabled for this account.',
            ),
          ),
        ],
      ),
    );
  }
}
