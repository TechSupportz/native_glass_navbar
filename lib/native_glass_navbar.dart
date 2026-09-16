/// A Flutter plugin that provides a native liquid glass navigation bar for iOS.
library native_glass_navbar;

export 'liquid_glass_helper.dart';

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_glass_navbar/liquid_glass_helper.dart';
import 'package:native_glass_navbar/src/native_tab_config.dart';

/// Represents a tab item in the [NativeGlassNavBar].
class NativeGlassNavBarItem {
  /// The label text to display for the tab.
  final String label;

  /// The SF Symbol name to use for the tab icon.
  final String symbol;

  /// The SF Symbol to use while this tab is selected.
  final String? selectedSymbol;

  /// Creates a new [NativeGlassNavBarItem].
  const NativeGlassNavBarItem({
    required this.label,
    required this.symbol,
    this.selectedSymbol,
  });
}

/// Represents an action button in the [NativeGlassNavBar].
///
/// It appears to the right of the tab as a circular floating button.
class TabBarActionButton {
  /// The SF Symbol name to use for the action button icon.
  final String symbol;

  /// The callback to be invoked when the action button is tapped.
  final VoidCallback onTap;

  /// Creates a new [TabBarActionButton].
  const TabBarActionButton({required this.symbol, required this.onTap});
}

/// A widget that displays a native glass liquid navigation bar on iOS.
///
/// On non-iOS platforms or when the glass effect is not supported,
/// it can optionally display a [fallback] widget.
class NativeGlassNavBar extends StatefulWidget {
  /// The list of tabs to display in the navigation bar.
  ///
  /// If [actionButton] is provided, supports up to 4 tabs, else supports up to 5 tabs.
  final List<NativeGlassNavBarItem> tabs;

  /// An optional action button.
  ///
  /// If provided, the action button appears to the right of the tabs as a circular floating button.
  final TabBarActionButton? actionButton;

  /// The index of the currently selected tab.
  final int currentIndex;

  /// A callback that is called when a tab is tapped.
  final ValueChanged<int> onTap;

  /// The color to use for the selected tab icon and label.
  ///
  /// If null, defaults to the primary color of the current [Theme].
  final Color? tintColor;

  /// A widget to display when the native glass effect is not supported.
  final Widget? fallback;

  /// Creates a new [NativeGlassNavBar].
  const NativeGlassNavBar({
    super.key,
    required this.tabs,
    this.actionButton,
    required this.currentIndex,
    required this.onTap,
    this.tintColor,
    this.fallback,
  }) : assert(
         tabs.length <= (actionButton == null ? 5 : 4),
         actionButton == null
             ? 'NativeGlassNavBar supports a maximum of 5 tabs.'
             : 'NativeGlassNavBar with an action button supports a maximum of 4 tabs.',
       );

  @override
  State<NativeGlassNavBar> createState() => _NativeGlassNavBarState();
}

class _NativeGlassNavBarState extends State<NativeGlassNavBar> {
  MethodChannel? _channel;
  late Future<bool> _supportLiquidGlassFuture;
  _NativeGlassNavBarParams? _lastSentParams;

  void _updateNativeView() {
    final channel = _channel;
    if (channel == null) {
      return;
    }

    final params = _createParams();
    if (params == _lastSentParams) {
      return;
    }

    _lastSentParams = params;
    channel.invokeMethod('update', params.toMap());
  }

  Future<bool> checkLiquidGlassSupport() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return false;
    }

    return await LiquidGlassHelper.isLiquidGlassSupported();
  }

  _NativeGlassNavBarParams _createParams() {
    return _NativeGlassNavBarParams(
      tabs: widget.tabs
          .map((e) => NativeTabConfig(
                label: e.label,
                symbol: e.symbol,
                selectedSymbol: e.selectedSymbol,
              ))
          .toList(growable: false),
      actionButtonSymbol: widget.actionButton?.symbol ?? '',
      selectedIndex: widget.currentIndex,
      isDark: Theme.of(context).brightness == Brightness.dark,
      tintColor: widget.tintColor != null
          ? widget.tintColor!.toARGB32()
          : Theme.of(context).colorScheme.primary.toARGB32(),
    );
  }

  @override
  void initState() {
    super.initState();
    _supportLiquidGlassFuture = checkLiquidGlassSupport();
  }

  @override
  void didUpdateWidget(NativeGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateNativeView();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateNativeView();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _supportLiquidGlassFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.fallback ?? const SizedBox.shrink();
        }

        if (snapshot.data != true) {
          if (widget.fallback != null) {
            return widget.fallback!;
          }

          if (kDebugMode) {
            developer.log(
              'Liquid glass effect is not supported on this device. '
              'Falling back to an empty widget. Provide a `fallback` widget to handle this case.',
              name: 'NativeGlassNavBar',
              level: 900,
            );
          }
          return const SizedBox.shrink();
        }

        final bottomPadding = MediaQuery.of(context).padding.bottom;
        // Standard tab bar height is 49. Add bottom padding for safe area.
        final height = 49.0 + bottomPadding;
        final params = _createParams();

        return SizedBox(
          height: height,
          child: UiKitView(
            viewType: 'NativeTabBar',
            creationParams: params.toMap(),
            creationParamsCodec: const StandardMessageCodec(),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
            },
            onPlatformViewCreated: (id) {
              _channel = MethodChannel('NativeTabBar_$id');
              _lastSentParams = params;
              _channel!.setMethodCallHandler((call) async {
                if (call.method == 'valueChanged') {
                  final index = call.arguments['index'] as int;
                  _lastSentParams = (_lastSentParams ?? _createParams())
                      .copyWith(selectedIndex: index);
                  widget.onTap(index);
                }

                if (call.method == 'actionButtonPressed') {
                  widget.actionButton?.onTap();
                }
              });
            },
          ),
        );
      },
    );
  }
}

class _NativeGlassNavBarParams {
  const _NativeGlassNavBarParams({
    required this.tabs,
    required this.actionButtonSymbol,
    required this.selectedIndex,
    required this.isDark,
    required this.tintColor,
  });

  final List<NativeTabConfig> tabs;
  final String actionButtonSymbol;
  final int selectedIndex;
  final bool isDark;
  final int tintColor;

  Map<String, dynamic> toMap() {
    return createNativeTabBarParams(
      tabs: tabs,
      actionButtonSymbol: actionButtonSymbol,
      selectedIndex: selectedIndex,
      isDark: isDark,
      tintColor: tintColor,
    );
  }

  _NativeGlassNavBarParams copyWith({int? selectedIndex}) {
    return _NativeGlassNavBarParams(
      tabs: tabs,
      actionButtonSymbol: actionButtonSymbol,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isDark: isDark,
      tintColor: tintColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _NativeGlassNavBarParams &&
            _tabListsEqual(tabs, other.tabs) &&
            actionButtonSymbol == other.actionButtonSymbol &&
            selectedIndex == other.selectedIndex &&
            isDark == other.isDark &&
            tintColor == other.tintColor;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(tabs.map((tab) => Object.hash(
        tab.label,
        tab.symbol,
        tab.selectedSymbol,
      ))),
      actionButtonSymbol,
      selectedIndex,
      isDark,
      tintColor,
    );
  }
}

bool _tabListsEqual(List<NativeTabConfig> a, List<NativeTabConfig> b) {
  if (a.length != b.length) {
    return false;
  }

  for (var i = 0; i < a.length; i++) {
    if (a[i].label != b[i].label ||
        a[i].symbol != b[i].symbol ||
        a[i].selectedSymbol != b[i].selectedSymbol) {
      return false;
    }
  }

  return true;
}
