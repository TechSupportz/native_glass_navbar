import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

/// A circular icon button rendered natively, with a Liquid Glass backdrop
/// on iOS 26+ and an auto-upgraded system-material blur on earlier iOS.
///
/// Like [NativeGlassNavBar], you can supply either an SF [symbol] name or
/// any Flutter [iconData] (Lucide, Material, etc.). On non-iOS or
/// unsupported devices, the optional [fallback] widget is shown — pass your
/// own Flutter-side glass approximation there.
///
/// Sizing is controlled by the caller: wrap in a `SizedBox` (or any
/// constraint-providing parent) and the native view fills it. Defaults to
/// 40×40 if no parent constraint applies.
class NativeGlassButton extends StatefulWidget {
  /// Creates a new [NativeGlassButton]. At least one of [symbol] or
  /// [iconData] must be provided.
  const NativeGlassButton({
    super.key,
    required this.onTap,
    this.symbol,
    this.iconData,
    this.size = 40,
    this.iconColor,
    this.fallback,
  }) : assert(symbol != null || iconData != null,
            'Provide either an SF symbol name or an IconData.');

  /// Callback invoked when the user taps the button.
  final VoidCallback onTap;

  /// SF Symbol name (e.g. `'person.fill'`). Used directly when [iconData]
  /// is null, or as a hint otherwise.
  final String? symbol;

  /// A Flutter [IconData] to rasterise and pass natively. Takes precedence
  /// over [symbol] on iOS.
  final IconData? iconData;

  /// Display size (point side length) of the circular button.
  final double size;

  /// Override the icon tint. Defaults to the iOS dynamic `.label` colour
  /// when null, which adapts to light/dark mode automatically.
  final Color? iconColor;

  /// Widget shown on non-iOS platforms or when Liquid Glass isn't supported.
  final Widget? fallback;

  @override
  State<NativeGlassButton> createState() => _NativeGlassButtonState();
}

class _NativeGlassButtonState extends State<NativeGlassButton> {
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
    // Render at 3× display size to match Swift's `scale: 3.0` decoder, so
    // a 20pt display icon (default ~half the 40pt button) reads crisply.
    final px = (widget.size * 0.5) * 3;
    final bytes = await rasteriseIconData(iconData, size: px);
    if (!mounted) return;
    setState(() {
      _renderedIcon = bytes;
      _iconReady = true;
    });
  }

  Map<String, dynamic> _createParams() {
    return {
      'symbol': widget.symbol ?? '',
      'iconBytes': _renderedIcon,
      'iconColor': widget.iconColor?.toARGB32(),
      'isDark': Theme.of(context).brightness == Brightness.dark,
    };
  }

  void _updateNative() {
    _channel?.invokeMethod('update', _createParams());
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
  void didUpdateWidget(NativeGlassButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconData != widget.iconData ||
        oldWidget.size != widget.size) {
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
          return SizedBox(width: widget.size, height: widget.size);
        }

        if (snapshot.data != true) {
          if (widget.fallback != null) return widget.fallback!;
          if (kDebugMode) {
            developer.log(
              'Liquid glass is not supported on this device. Provide a '
              '`fallback` widget to handle this case.',
              name: 'NativeGlassButton',
              level: 900,
            );
          }
          return SizedBox(width: widget.size, height: widget.size);
        }

        if (widget.iconData != null && !_iconReady) {
          return SizedBox(width: widget.size, height: widget.size);
        }

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: UiKitView(
            viewType: 'NativeGlassButton',
            creationParams: _createParams(),
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (id) {
              _channel = MethodChannel('NativeGlassButton_$id');
              _channel!.setMethodCallHandler((call) async {
                if (call.method == 'buttonPressed') {
                  widget.onTap();
                }
              });
            },
          ),
        );
      },
    );
  }
}
