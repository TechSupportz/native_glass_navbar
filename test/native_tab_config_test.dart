import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass_navbar/src/native_tab_config.dart';

void main() {
  test('uses the normal symbol when no selected symbol is configured', () {
    const config = NativeTabConfig(label: 'Home', symbol: 'house');

    expect(config.toMap(), {
      'label': 'Home',
      'symbol': 'house',
      'selectedSymbol': 'house',
      'badgeValue': null,
    });
  });

  test('keeps each tab configuration together in the channel payload', () {
    final params = createNativeTabBarParams(
      tabs: const [
        NativeTabConfig(
          label: 'Home',
          symbol: 'house',
          selectedSymbol: 'house.fill',
          badgeValue: '3',
        ),
        NativeTabConfig(label: 'Search', symbol: 'magnifyingglass'),
      ],
      actionButtonSymbol: null,
      selectedIndex: 0,
      isDark: false,
      tintColor: 0xFF007AFF,
    );

    expect(params, {
      'tabs': [
        {
          'label': 'Home',
          'symbol': 'house',
          'selectedSymbol': 'house.fill',
          'badgeValue': '3',
        },
        {
          'label': 'Search',
          'symbol': 'magnifyingglass',
          'selectedSymbol': 'magnifyingglass',
          'badgeValue': null,
        },
      ],
      'actionButtonSymbol': null,
      'selectedIndex': 0,
      'isDark': false,
      'tintColor': 0xFF007AFF,
    });
    expect(params, isNot(contains('labels')));
    expect(params, isNot(contains('symbols')));
    final encoded = const StandardMessageCodec().encodeMessage(params);
    expect(const StandardMessageCodec().decodeMessage(encoded), params);
  });
}
