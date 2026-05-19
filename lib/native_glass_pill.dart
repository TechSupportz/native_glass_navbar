import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

/// A capsule-shaped native glass pill / badge: short text with an optional
/// leading icon. Renders with Apple's Liquid Glass material on iOS 26+ and
/// the system-material blur on earlier iOS.
///
/// Use it for status chips ("Ready"), credit badges ("5 credits"), tag
/// pills ("modern"), and any floating native label.
///
/// Pass [onTap] to make the pill interactive — on iOS 26+ this enables the
/// real `UIButton.Configuration.glass()` press animation. Without [onTap]
/// the pill is a static decoration.
///
/// Sizing is content-driven by default — the pill grows to fit the text
/// and icon. Wrap in a parent constraint if you need a fixed size.
class NativeGlassPill extends StatefulWidget {
  /// Creates a new [NativeGlassPill]. [text] is required.
  const NativeGlassPill({
    super.key,
    required this.text,
    this.iconData,
    this.symbol,
    this.onTap,
    this.prominent = false,
    this.foregroundColor,
    this.fallback,
  });

  /// Label text rendered inside the pill.
  final String text;

  /// Optional Flutter [IconData] (Lucide, Material, etc.) rendered before
  /// the text. Takes precedence over [symbol] on iOS.
  final IconData? iconData;

  /// Optional SF Symbol name used as a fallback when [iconData] is null.
  final String? symbol;

  /// Tap callback. When provided AND the device supports interactive
  /// glass (iOS 26+), the pill renders with the press animation.
  final VoidCallback? onTap;

  /// On iOS 26+, use the bolder `prominentGlass()` button style. No effect
  /// on earlier iOS or when [onTap] is null.
  final bool prominent;

  /// Override the icon + text tint. Defaults to the iOS dynamic `.label`
  /// colour.
  final Color? foregroundColor;

  /// Widget shown on non-iOS platforms or when Liquid Glass isn't supported.
  final Widget? fallback;

  @override
  State<NativeGlassPill> createState() => _NativeGlassPillState();
}

class _NativeGlassPillState extends State<NativeGlassPill> {
  MethodChannel? _channel;
  late Future<bool> _supportFuture;
  Uint8List? _renderedIcon;
  bool _iconReady = false;

  Future<bool> _checkSupport() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    return LiquidGlassHelper.isLiquidGlassSupported();
  }

  Future<void> _renderIcon() async {
    final iconData = widget.iconData;
    if (iconData == null) {
      if (!mounted) return;
      setState(() {
        _renderedIcon = null;
        _iconReady = true;
      });
      return;
    }
    // 48px source = 16pt display @3x — matches the pill's icon size cap.
    final bytes = await rasteriseIconData(iconData, size: 48);
    if (!mounted) return;
    setState(() {
      _renderedIcon = bytes;
      _iconReady = true;
    });
  }

  Map<String, dynamic> _createParams() {
    return {
      'text': widget.text,
      'symbol': widget.symbol ?? '',
      'iconBytes': _renderedIcon,
      'foregroundColor': widget.foregroundColor?.toARGB32(),
      'prominent': widget.prominent,
      'interactive': widget.onTap != null,
      'isDark': Theme.of(context).brightness == Brightness.dark,
    };
  }

  void _updateNative() {
    _channel?.invokeMethod('update', _createParams());
  }

  /// Computes the required pill width from the text label.
  /// UiKitView reports 0 intrinsic width, so we measure on the Flutter side.
  /// UIKit .footnote ≈ 13 sp; add 14px horizontal padding each side + icon.
  double _measurePillWidth(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final hasIcon = _renderedIcon != null ||
        (widget.symbol != null && widget.symbol!.isNotEmpty);
    final iconWidth = hasIcon ? 22.0 : 0.0; // 16px icon + 6px gap
    return (painter.width + iconWidth + 28).clamp(48.0, 280.0);
  }

  @override
  void initState() {
    super.initState();
    _supportFuture = _checkSupport();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_renderIcon());
    });
  }

  @override
  void didUpdateWidget(NativeGlassPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconData != widget.iconData) {
      _iconReady = false;
      unawaited(_renderIcon());
    } else {
      _updateNative();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _supportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.data != true) {
          if (widget.fallback != null) return widget.fallback!;
          if (kDebugMode) {
            developer.log(
              'Liquid glass is not supported on this device. Provide a '
              '`fallback` widget to handle this case.',
              name: 'NativeGlassPill',
              level: 900,
            );
          }
          return const SizedBox.shrink();
        }

        if (widget.iconData != null && !_iconReady) {
          return const SizedBox.shrink();
        }

        // UiKitView doesn't implement intrinsic sizing, so IntrinsicWidth
        // resolves to 0 and the pill is invisible. Measure text explicitly.
        final pillWidth = _measurePillWidth(context);
        return SizedBox(
          width: pillWidth,
          height: 28,
          child: UiKitView(
            viewType: 'NativeGlassPill',
            creationParams: _createParams(),
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (id) {
              _channel = MethodChannel('NativeGlassPill_$id');
              _channel!.setMethodCallHandler((call) async {
                if (call.method == 'pillPressed') {
                  widget.onTap?.call();
                }
              });
            },
          ),
        );
      },
    );
  }
}
