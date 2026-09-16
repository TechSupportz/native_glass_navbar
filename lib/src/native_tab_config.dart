/// A single tab's serialized configuration for the native method channel.
class NativeTabConfig {
  /// Creates a native tab configuration.
  const NativeTabConfig({
    required this.label,
    required this.symbol,
    String? selectedSymbol,
  }) : selectedSymbol = selectedSymbol ?? symbol;

  /// The tab's visible label.
  final String label;

  /// The icon used while the tab is not selected.
  final String symbol;

  /// The icon used while the tab is selected.
  final String selectedSymbol;

  /// Serializes this tab without splitting its fields into parallel arrays.
  Map<String, String> toMap() {
    return {'label': label, 'symbol': symbol, 'selectedSymbol': selectedSymbol};
  }
}

/// Creates the complete argument payload sent to the native tab bar.
Map<String, Object?> createNativeTabBarParams({
  required Iterable<NativeTabConfig> tabs,
  required String? actionButtonSymbol,
  required int selectedIndex,
  required bool isDark,
  required int tintColor,
}) {
  return {
    'tabs': tabs.map((tab) => tab.toMap()).toList(growable: false),
    'actionButtonSymbol': actionButtonSymbol,
    'selectedIndex': selectedIndex,
    'isDark': isDark,
    'tintColor': tintColor,
  };
}
