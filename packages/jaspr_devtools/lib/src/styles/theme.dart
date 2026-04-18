import 'package:jaspr/dom.dart';

abstract class ThemeColors {
  static const primary = Color('#a3c9ff');
  static const primaryContainer = Color('#3399ff');
  static const secondary = Color('#dab9ff');
  static const secondaryContainer = Color('#602b9d');
  static const onSecondaryContainer = Color('#cfa7ff');
  static const tertiary = Color('#ffb86c');

  static const background = Color('#131313');
  static const surface = Color('#131313');
  static const surfaceVariant = Color('#404753');
  static const onSurface = Color('#e5e2e1');
  static const onSurfaceVariant = Color('#c0c7d5');

  static const surfaceContainerLowest = Color('#0e0e0e');
  static const surfaceContainerLow = Color('#1b1b1c');
  static const surfaceContainer = Color('#212121');
  static const surfaceContainerHigh = Color('#2a2a2a');
  static const surfaceContainerHighest = Color('#353535');

  static const outlineVariant = Color('#404753');
}

abstract class ThemeSpacing {
  static final s1 = 0.2.rem;
  static final s2 = 0.4.rem;
  static final s2_5 = 0.5.rem;
  static final s3 = 0.6.rem;
  static final s4 = 0.8.rem;
  static final s6 = 1.2.rem;
  static final s8 = 1.6.rem;

  static final r1 = 4.px;
}

final _defaultFont = FontFamily.list([
  FontFamily('Open Sans'),
  FontFamilies.uiSansSerif,
  FontFamilies.systemUi,
  FontFamilies.sansSerif,
  FontFamily('Apple Color Emoji'),
  FontFamily('Segoe UI Emoji'),
  FontFamily('Segoe UI Symbol'),
  FontFamily('Noto Color Emoji'),
]);

final _defaultCodeFont = FontFamily.list([
  FontFamily('JetBrains Mono'),
  FontFamilies.uiMonospace,
  FontFamily('SFMono-Regular'),
  FontFamily('Menlo'),
  FontFamily('Monaco'),
  FontFamily('Consolas'),
  FontFamily('Liberation Mono'),
  FontFamilies.courierNew,
  FontFamilies.monospace,
]);

abstract class ThemeTypography {
  static final bodySm = Styles(
    color: ThemeColors.onSurface,
    fontFamily: _defaultFont,
    fontSize: 0.75.rem,
  );

  static final bodyMd = Styles(
    color: ThemeColors.onSurface,
    fontFamily: _defaultFont,
    fontSize: 0.875.rem,
  );

  static final labelSm = Styles(
    color: ThemeColors.onSurfaceVariant,
    fontFamily: _defaultFont,
    fontSize: 0.75.rem,
  );

  static final code = Styles(
    color: ThemeColors.onSurface,
    fontFamily: _defaultCodeFont,
    fontSize: 0.875.rem,
  );

  static final headline = Styles(
    color: ThemeColors.onSurface,
    fontFamily: _defaultFont,
    fontSize: 1.25.rem,
    fontWeight: FontWeight.bold,
  );
}

@css
List<StyleRule> get resetStyles => [
  css('*, :after, :before').styles(
    boxSizing: BoxSizing.borderBox,
    border: Border.all(width: Unit.zero, style: BorderStyle.solid, color: Color('#e5e7eb')),
  ),
  css(':host,html').styles(
    fontFamily: _defaultFont,
    lineHeight: 1.5.em,
    raw: {
      '-webkit-text-size-adjust': '100%',
      '-moz-tab-size': '4',
      'tab-size': '4',
      'font-feature-settings': 'normal',
      'font-variation-settings': 'normal',
      '-webkit-tap-highlight-color': 'transparent',
    },
  ),
  css('body').styles(margin: Margin.zero, lineHeight: Unit.inherit, raw: {'-webkit-font-smoothing': 'antialiased'}),
  css('hr').styles(
    height: Unit.zero,
    border: Border.only(top: BorderSide(width: 1.px)),
    color: Color.inherit,
  ),
  css('a').styles(color: Color.inherit, textDecoration: TextDecoration.inherit),
  css('b, strong').styles(fontWeight: FontWeight.bolder),
  css(
    'code, kbd, pre, samp',
  ).styles(fontSize: 1.em, raw: {'font-feature-settings': 'normal', 'font-variation-settings': 'normal'}),
  css('small').styles(fontSize: 80.percent),
  css('sub, sup').styles(
    position: Position.relative(),
    fontSize: 75.percent,
    lineHeight: Unit.zero,
    raw: {'vertical-align': 'baseline'},
  ),
  css('sub').styles(position: Position.relative(bottom: (-0.25).em)),
  css('sup').styles(position: Position.relative(top: (-0.5).em)),
  css('table').styles(
    border: Border.all(color: Color.inherit),
    textIndent: Unit.zero,
    raw: {'border-collapse': 'collapse'},
  ),
  css('button, input, optgroup, select, textarea').styles(
    padding: Padding.zero,
    margin: Margin.zero,
    color: Color.inherit,
    fontFamily: FontFamily.inherit,
    fontSize: 100.percent,
    fontWeight: FontWeight.inherit,
    letterSpacing: Unit.inherit,
    lineHeight: Unit.inherit,
    raw: {'font-feature-settings': 'inherit', 'font-variation-settings': 'inherit'},
  ),
  css('button, select').styles(textTransform: TextTransform.none),
  css(
    'button, input[type=button], input[type=reset], input[type=submit]',
  ).styles(raw: {'-webkit-appearance': 'button', 'background-color': 'transparent', 'background-image': 'none'}),
  css(':-moz-focusring').styles(raw: {'outline': 'auto'}),
  css(':-moz-ui-invalid').styles(raw: {'box-shadow': 'none'}),
  css('progress').styles(raw: {'vertical-align': 'baseline'}),
  css('::-webkit-inner-spin-button, ::-webkit-outer-spin-button').styles(height: Unit.auto),
  css('[type=search]').styles(raw: {'-webkit-appearance': 'textfield', 'outline-offset': '-2px'}),
  css('::-webkit-search-decoration').styles(raw: {'-webkit-appearance': 'none'}),
  css('::-webkit-file-upload-button').styles(raw: {'-webkit-appearance': 'button', 'font': 'inherit'}),
  css('summary').styles(display: Display.listItem),
  css('blockquote, dd, dl, figure, h1, h2, h3, h4, h5, h6, hr, p, pre').styles(margin: Margin.zero),
  css('fieldset').styles(margin: Margin.zero),
  css('fieldset, legend').styles(padding: Padding.zero),
  css('menu, ol, ul').styles(padding: Padding.zero, margin: Margin.zero, listStyle: ListStyle.none),
  css('dialog').styles(padding: Padding.zero),
  css('textarea').styles(raw: {'resize': 'vertical'}),
  css('input::placeholder, textarea::placeholder').styles(opacity: 1, color: Color('#9ca3af')),
  css('[role=button], button').styles(cursor: Cursor.pointer),
  css(':disabled').styles(cursor: Cursor.defaultCursor),
  css(
    'audio, canvas, embed, iframe, img, object, svg, video',
  ).styles(display: Display.block, raw: {'vertical-align': 'middle'}),
  css('img, video').styles(height: Unit.auto, maxWidth: 100.percent),
];
