import 'package:flutter/material.dart';

import '../models/navigation_item.dart';

// =============================================================================
// Presentation Layer — CustomBottomNavigationBar
// =============================================================================
// This widget is a pure presentation component that depends only on the domain
// entity [NavigationItem] and Flutter's [BottomNavigationBar].
//
// Responsibilities:
//   - Renders a styled bottom navigation bar.
//   - Maps domain [NavigationItem] entities to Flutter [BottomNavigationBarItem]s.
//   - Delegates user interaction via the [onTap] callback.
//
// Design principles applied:
//   - Single Responsibility: only handles rendering of bottom nav UI.
//   - Dependency Inversion: depends on domain abstraction [NavigationItem],
//     not on concrete Flutter widgets for item configuration.
//   - Open/Closed: styling can be overridden via constructor parameters
//     without modifying the widget itself.
// =============================================================================

/// A reusable bottom navigation bar widget built with Clean Architecture.
///
/// Accepts a list of domain [NavigationItem]s and renders them as a styled
/// [BottomNavigationBar]. All visual configuration is exposed through
/// constructor parameters with sensible defaults.
class CustomBottomNavigationBar extends StatelessWidget {
  /// The index of the currently selected item.
  final int currentIndex;

  /// Callback invoked when the user taps a navigation item.
  /// Receives the index of the tapped item.
  final ValueChanged<int> onTap;

  /// The list of navigation items to display.
  /// Each item is a domain [NavigationItem] entity.
  final List<NavigationItem> items;

  /// The background color of the navigation bar.
  /// Defaults to [Colors.white].
  final Color backgroundColor;

  /// The color applied to the selected item's icon and label.
  /// Defaults to [Colors.blue].
  final Color selectedItemColor;

  /// The color applied to unselected items' icons and labels.
  /// Defaults to [Colors.grey].
  final Color unselectedItemColor;

  /// Whether to show a top border divider.
  /// Defaults to `true`.
  final bool showTopBorder;

  /// The color of the top border divider.
  /// Defaults to [Colors.grey] shade 300.
  final Color topBorderColor;

  /// Creates a [CustomBottomNavigationBar].
  ///
  /// [currentIndex], [onTap], and [items] are required.
  /// All styling parameters are optional with sensible defaults.
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor = Colors.white,
    this.selectedItemColor = Colors.blue,
    this.unselectedItemColor = Colors.grey,
    this.showTopBorder = true,
    this.topBorderColor = const Color(0xFFE0E0E0), // grey.shade300
  });

  /// Factory constructor that automatically applies theme colors.
  factory CustomBottomNavigationBar.themed({
    required int currentIndex,
    required ValueChanged<int> onTap,
    required List<NavigationItem> items,
    required BuildContext context,
    bool showTopBorder = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomBottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      showTopBorder: showTopBorder,
      topBorderColor: colorScheme.outlineVariant,
    );
  }

  /// Maps a domain [NavigationItem] to a Flutter [BottomNavigationBarItem].
  ///
  /// This is the boundary mapping between the domain layer and the
  /// presentation layer. Icons are reconstructed from codepoints stored
  /// in the domain entity.
  BottomNavigationBarItem _buildBarItem(NavigationItem item) {
    final icon = Icon(
      IconData(item.iconCodePoint, fontFamily: 'MaterialIcons'),
    );
    final activeIcon = item.activeIconCodePoint != null
        ? Icon(IconData(item.activeIconCodePoint!, fontFamily: 'MaterialIcons'))
        : icon;

    return BottomNavigationBarItem(
      icon: icon,
      activeIcon: activeIcon,
      label: item.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomNav = BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      items: items.map(_buildBarItem).toList(),
    );

    if (!showTopBorder) {
      return bottomNav;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: topBorderColor)),
      ),
      child: bottomNav,
    );
  }
}
