import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../routes/app_router.dart';
import '../../services/auth_service.dart';
import 'personal_info_screen.dart';
import 'notifications_screen.dart';
import 'appearance_screen.dart';
import 'security_screen.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.clearTokens();
    if (context.mounted) {
      context.router.replaceAll([const LoginRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Manage your account and preferences',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingsButton(
              context,
              icon: Icons.person,
              label: 'Personal Info',
              screen: const PersonalInfoScreen(),
            ),
            _buildSettingsButton(
              context,
              icon: Icons.notifications,
              label: 'Notifications',
              screen: const NotificationsScreen(),
            ),
            _buildSettingsButton(
              context,
              icon: Icons.palette,
              label: 'Appearance',
              screen: const AppearanceScreen(),
            ),
            _buildSettingsButton(
              context,
              icon: Icons.shield,
              label: 'Security',
              screen: const SecurityScreen(),
            ),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget screen,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateTo(context, screen),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 28,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 16),
                    Text(label, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.errorContainer),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _handleLogout(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.logout,
                      size: 28,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
