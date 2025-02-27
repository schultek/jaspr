import 'package:jaspr/jaspr.dart';

import 'page.dart';

abstract class LayoutsConfig {
  factory LayoutsConfig({
    required LayoutsConfigCallback defaultLayout,
    Map<String, LayoutsConfigCallback> layouts,
  }) = BaseLayoutsConfig;

  Component buildLayout(Page page, Component child);
}

typedef LayoutsConfigCallback = Component Function(Component child);

class BaseLayoutsConfig implements LayoutsConfig {
  BaseLayoutsConfig({required this.defaultLayout, this.layouts = const {}});

  final LayoutsConfigCallback defaultLayout;
  final Map<String, LayoutsConfigCallback> layouts;

  @override
  Component buildLayout(Page page, Component child) {
    final layout = page.data['layout'];
    final builder = layouts[layout];
    if (builder != null) {
      return builder(child);
    } else {
      return defaultLayout(child);
    }
  }
}
