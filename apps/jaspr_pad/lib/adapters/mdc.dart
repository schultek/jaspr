import 'package:jaspr/jaspr.dart';

@Import.onWeb(
  'package:mdc_web/mdc_web.dart',
  show: [#MDCRipple, #MDCDialog, #MDCMenu, #AnchorCorner, #MDCSnackbar, #MDCTabBar, #MDCTextField],
)
export 'mdc.imports.dart';
