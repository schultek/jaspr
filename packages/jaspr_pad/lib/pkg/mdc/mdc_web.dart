import 'package:mdc_web/mdc_web.dart';

export 'package:mdc_web/mdc_web.dart';

MDCRipple attachRipple(dynamic element, {bool isIcon = false}) {
  return MDCRipple(element)..unbounded = isIcon;
}

MDCTabBar attachTabBar(dynamic element) {
  return MDCTabBar(element);
}
