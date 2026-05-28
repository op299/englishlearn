/// Domain entity representing a navigation item in the bottom navigation bar.
///
/// This is a **pure domain object** with zero dependency on Flutter or any
/// external framework. Uses [iconCodePoint] (int) instead of Flutter [IconData]
/// to maintain complete framework independence.
class NavigationItem {
  /// The codepoint of the Material icon for this navigation item.
  final int iconCodePoint;

  /// Optional codepoint for the active (selected) state icon.
  /// If null, [iconCodePoint] is used for both states.
  final int? activeIconCodePoint;

  /// The display label for this navigation item.
  final String label;

  /// Creates a const [NavigationItem].
  ///
  /// [iconCodePoint] should be a valid Material Icons codepoint,
  /// e.g. `Icons.home.codePoint` (0xe88a).
  /// [activeIconCodePoint] is optional and used when the item is selected.
  const NavigationItem({
    required this.iconCodePoint,
    this.activeIconCodePoint,
    required this.label,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationItem &&
        other.iconCodePoint == iconCodePoint &&
        other.activeIconCodePoint == activeIconCodePoint &&
        other.label == label;
  }

  @override
  int get hashCode =>
      iconCodePoint.hashCode ^ activeIconCodePoint.hashCode ^ label.hashCode;

  @override
  String toString() =>
      'NavigationItem(iconCodePoint: $iconCodePoint, label: $label)';
}
