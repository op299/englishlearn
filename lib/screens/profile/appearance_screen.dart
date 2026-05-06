import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  late String _selectedTheme;
  final _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _selectedTheme = _themeService.getCurrentTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Customize your visual interface experience.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildThemeCard(
              context,
              title: 'Light Theme',
              subtitle: 'Studio White',
              description:
                  'High-contrast, architectural layout for focused daytime learning.',
              themeValue: 'light',
              previewBuilder: () => _buildLightThemePreview(),
              isSelected: _selectedTheme == 'light',
            ),
            const SizedBox(height: 16),
            _buildThemeCard(
              context,
              title: 'Dark Theme',
              subtitle: 'Midnight Slate',
              description:
                  'Deep charcoal tones designed to reduce eye strain during evening sessions.',
              themeValue: 'dark',
              previewBuilder: () => _buildDarkThemePreview(),
              isSelected: _selectedTheme == 'dark',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String themeValue,
    required Widget Function() previewBuilder,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        await _themeService.setTheme(themeValue);
        setState(() {
          _selectedTheme = themeValue;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Theme changed to $title'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and checkbox
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: isSelected ? Colors.blue : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
            // Preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: previewBuilder(),
            ),
            const SizedBox(height: 16),
            // Subtitle and description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLightThemePreview() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Stack(
        children: [
          // Header area
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Sun icon
          Positioned(
            top: 60,
            left: 100,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.wb_sunny, size: 24, color: Colors.amber),
            ),
          ),
          // Content bar
          Positioned(
            bottom: 16,
            left: 16,
            width: 100,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Decorative shape
          Positioned(
            bottom: 20,
            right: 16,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkThemePreview() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade900,
      ),
      child: Stack(
        children: [
          // Header area
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Moon icon
          Positioned(
            top: 60,
            left: 100,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.nights_stay,
                size: 24,
                color: Colors.grey,
              ),
            ),
          ),
          // Content bar
          Positioned(
            bottom: 16,
            left: 16,
            width: 100,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Decorative shape
          Positioned(
            bottom: 20,
            right: 16,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
