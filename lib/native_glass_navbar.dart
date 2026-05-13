/// A Flutter plugin that provides a native liquid glass navigation bar for iOS.
library native_glass_navbar;

export 'liquid_glass_helper.dart';
export 'native_glass_button.dart';

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_glass_navbar/liquid_glass_helper.dart';

/// Represents a tab item in the [NativeGlassNavBar].
///
/// You can supply either:
/// - an SF [symbol] name (e.g. `'house'`), rendered natively by UIKit, OR
/// - a Flutter [iconData] (e.g. a Lucide or Material icon), which the plugin
///   rasterises to a PNG and sends to UIKit as a template image.
///
/// At least one must be provided. If both are supplied, [iconData] wins on
/// iOS and [symbol] is kept as a documentation hint.
class NativeGlassNavBarItem {
  /// The label text to display for the tab.
  final String label;

  /// The SF Symbol name to use for the tab icon (e.g. `'house'`).
  final String? symbol;

  /// A Flutter [IconData] (Lucide, Material, Cupertino, etc.) to render and
  /// pass natively. The plugin handles rasterisation; you do not need to
  /// pre-render anything.
  final IconData? iconData;

  /// Creates a new [NativeGlassNavBarItem].
  const NativeGlassNavBarItem({
    required this.label,
    this.symbol,
    this.iconData,
  }) : assert(symbol != null || iconData != null,
            'Provide either an SF symbol name or an IconData.');
}

/// Represents an action button in the [NativeGlassNavBar].
///
/// Appears to the right of the tabs as a circular floating button.
class TabBarActionButton {
  /// The SF Symbol name to use for the action button icon.
  final String? symbol;

  /// A Flutter [IconData] to render as the action button icon. Takes
  /// precedence over [symbol] on iOS.
  final IconData? iconData;

  /// The callback invoked when the action button is tapped.
  final VoidCallback onTap;

  /// Creates a new [TabBarActionButton].
  const TabBarActionButton({
    required this.onTap,
    this.symbol,
    this.iconData,
  }) : assert(symbol != null || iconData != null,
            'Provide either an SF symbol name or an IconData.');
}

/// Rasterises an [IconData] to a transparent PNG suitable for use as a
/// UIKit template image. Renders the glyph in solid white; UIKit applies
/// the bar's tint colour at runtime.
///
/// The default [size] of 75 pixels matches the standard 25 pt tab bar icon
/// at @3x rendering — the Swift side decodes with `scale: 3.0`. Override
/// only if you need a larger source raster (e.g. for non-tab-bar uses).
///
/// Cached internally by the widget; you generally don't need to call this
/// directly. Exposed for tests and advanced use.
Future<Uint8List> rasteriseIconData(
  IconData icon, {
  double size = 75,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final textPainter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: size,
        color: Colors.white,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  // Centre the glyph in the square canvas — TextPainter lays out flush left.
  final dx = (size - textPainter.width) / 2;
  final dy = (size - textPainter.height) / 2;
  textPainter.paint(canvas, Offset(dx, dy));
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.ceil(), size.ceil());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return byteData!.buffer.asUint8List();
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

  /// Rasterised tab icons, indexed by tab position. Populated lazily.
  final List<Uint8List?> _renderedTabIcons = <Uint8List?>[];

  /// Rasterised action-button icon, if [TabBarActionButton.iconData] was used.
  Uint8List? _renderedActionIcon;

  bool _iconsReady = false;

  void _updateNativeView() {
    if (_channel != null) {
      _channel!.invokeMethod('update', _createParams());
    }
  }

  Future<bool> checkLiquidGlassSupport() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return false;
    }

    return await LiquidGlassHelper.isLiquidGlassSupported();
  }

  /// Renders any [IconData] tabs/action to PNG bytes and triggers a rebuild
  /// when complete. Skips entries that only specify an SF symbol.
  Future<void> _renderIcons() async {
    final rendered = <Uint8List?>[];
    for (final tab in widget.tabs) {
      if (tab.iconData != null) {
        rendered.add(await rasteriseIconData(tab.iconData!));
      } else {
        rendered.add(null);
      }
    }
    Uint8List? actionRendered;
    final actionIcon = widget.actionButton?.iconData;
    if (actionIcon != null) {
      actionRendered = await rasteriseIconData(actionIcon);
    }
    if (!mounted) return;
    setState(() {
      _renderedTabIcons
        ..clear()
        ..addAll(rendered);
      _renderedActionIcon = actionRendered;
      _iconsReady = true;
    });
  }

  Map<String, dynamic> _createParams() {
    return {
      'labels': widget.tabs.map((e) => e.label).toList(),
      'symbols': widget.tabs.map((e) => e.symbol ?? '').toList(),
      // Bytes aligned with `symbols`. A null entry means "use the symbol".
      'iconBytes': List<Uint8List?>.generate(
        widget.tabs.length,
        (i) => i < _renderedTabIcons.length ? _renderedTabIcons[i] : null,
      ),
      'actionButtonSymbol': widget.actionButton?.symbol ?? '',
      'actionButtonIconBytes': _renderedActionIcon,
      'hasActionButton': widget.actionButton != null,
      'selectedIndex': widget.currentIndex,
      'isDark': Theme.of(context).brightness == Brightness.dark,
      'tintColor': widget.tintColor != null
          ? widget.tintColor!.toARGB32()
          : Theme.of(context).colorScheme.primary.toARGB32(),
    };
  }

  bool _iconConfigChanged(NativeGlassNavBar old) {
    if (old.tabs.length != widget.tabs.length) return true;
    for (var i = 0; i < widget.tabs.length; i++) {
      if (old.tabs[i].iconData != widget.tabs[i].iconData) return true;
    }
    if (old.actionButton?.iconData != widget.actionButton?.iconData) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _supportLiquidGlassFuture = checkLiquidGlassSupport();
    // Rasterise after the first frame so that any custom icon font
    // (Lucide, Material, etc.) has had a chance to load. Calling
    // [rasteriseIconData] before the engine has loaded the font produces
    // a blank PNG, which is invisible inside the native UITabBarItem.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_renderIcons());
    });
  }

  @override
  void didUpdateWidget(NativeGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_iconConfigChanged(oldWidget)) {
      _iconsReady = false;
      unawaited(_renderIcons());
    } else {
      _updateNativeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _supportLiquidGlassFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
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

        // If any tab uses [iconData], wait for rasterisation before mounting
        // the UIKitView. Otherwise UIKit would show empty slots on first frame.
        final hasIconData = widget.tabs.any((t) => t.iconData != null) ||
            widget.actionButton?.iconData != null;
        if (hasIconData && !_iconsReady) {
          return const SizedBox.shrink();
        }

        final bottomPadding = MediaQuery.of(context).padding.bottom;
        // Standard tab bar height is 49. Add bottom padding for safe area.
        final height = 49.0 + bottomPadding;

        return SizedBox(
          height: height,
          child: UiKitView(
            viewType: 'NativeTabBar',
            creationParams: _createParams(),
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (id) {
              _channel = MethodChannel('NativeTabBar_$id');
              _channel!.setMethodCallHandler((call) async {
                if (call.method == 'valueChanged') {
                  final index = call.arguments['index'] as int;
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
