part of 'content.dart';
/// A default set of CSS reset styles.
final List<StyleRule> resetStyles = [
  css('*, :after, :before').styles(
    boxSizing: BoxSizing.borderBox,
    border: Border(width: Unit.zero, style: BorderStyle.solid, color: Color('#e5e7eb')),
  ),
  css(':host,html').styles(
    lineHeight: 1.5.em,
    fontFamily: FontFamily.list([
      FontFamily('Open Sans'),
      FontFamilies.uiSansSerif,
      FontFamilies.systemUi,
      FontFamilies.sansSerif,
      FontFamily('Apple Color Emoji'),
      FontFamily('Segoe UI Emoji'),
      FontFamily('Segoe UI Symbol'),
      FontFamily('Noto Color Emoji'),
    ]),
    raw: {
      '-webkit-text-size-adjust': '100%',
      '-moz-tab-size': '4',
      'tab-size': '4',
      'font-feature-settings': 'normal',
      'font-variation-settings': 'normal',
      '-webkit-tap-highlight-color': 'transparent',
    },
  ),
  css('body').styles(
    margin: Margin.zero,
    lineHeight: Unit.inherit,
    raw: {
      '-webkit-font-smoothing': 'antialiased',
    },
  ),
  css('hr').styles(
    height: Unit.zero,
    color: Color.inherit,
    border: Border.only(top: BorderSide(width: 1.px)),
  ),
  css('a').styles(
    color: Color.inherit,
    textDecoration: TextDecoration.inherit,
  ),
  css('b, strong').styles(
    fontWeight: FontWeight.bolder,
  ),
  css('code, kbd, pre, samp').styles(
    fontFamily: FontFamily.list([
      FontFamily('JetBrains Mono'),
      FontFamilies.uiMonospace,
      FontFamily('SFMono-Regular'),
      FontFamily('Menlo'),
      FontFamily('Monaco'),
      FontFamily('Consolas'),
      FontFamily('Liberation Mono'),
      FontFamilies.courierNew,
      FontFamilies.monospace,
    ]),
    fontSize: 1.em,
    raw: {
      'font-feature-settings': 'normal',
      'font-variation-settings': 'normal',
    },
  ),
  css('small').styles(
    fontSize: 80.percent,
  ),
  css('sub, sup').styles(
    fontSize: 75.percent,
    lineHeight: Unit.zero,
    position: Position.relative(),
    raw: {
      'vertical-align': 'baseline',
    },
  ),
  css('sub').styles(
    position: Position.relative(bottom: (-0.25).em),
  ),
  css('sup').styles(
    position: Position.relative(top: (-0.5).em),
  ),
  css('table').styles(
    textIndent: Unit.zero,
    border: Border(color: Color.inherit),
    raw: {
      'border-collapse': 'collapse',
    },
  ),
  css('button, input, optgroup, select, textarea').styles(
    fontFamily: FontFamily.inherit,
    fontSize: 100.percent,
    fontWeight: FontWeight.inherit,
    lineHeight: Unit.inherit,
    letterSpacing: Unit.inherit,
    color: Color.inherit,
    margin: Margin.zero,
    padding: Padding.zero,
    raw: {
      'font-feature-settings': 'inherit',
      'font-variation-settings': 'inherit',
    },
  ),
  css('button, select').styles(
    textTransform: TextTransform.none,
  ),
  css('button, input[type=button], input[type=reset], input[type=submit]').styles(
    raw: {
      '-webkit-appearance': 'button',
      'background-color': 'transparent',
      'background-image': 'none',
    },
  ),
  css(':-moz-focusring').styles(
    raw: {
      'outline': 'auto',
    },
  ),
  css(':-moz-ui-invalid').styles(
    raw: {
      'box-shadow': 'none',
    },
  ),
  css('progress').styles(
    raw: {
      'vertical-align': 'baseline',
    },
  ),
  css('::-webkit-inner-spin-button, ::-webkit-outer-spin-button').styles(
    height: Unit.auto,
  ),
  css('[type=search]').styles(
    raw: {
      '-webkit-appearance': 'textfield',
      'outline-offset': '-2px',
    },
  ),
  css('::-webkit-search-decoration').styles(
    raw: {
      '-webkit-appearance': 'none',
    },
  ),
  css('::-webkit-file-upload-button').styles(
    raw: {
      '-webkit-appearance': 'button',
      'font': 'inherit',
    },
  ),
  css('summary').styles(
    display: Display.listItem,
  ),
  css('blockquote, dd, dl, figure, h1, h2, h3, h4, h5, h6, hr, p, pre').styles(
    margin: Margin.zero,
  ),
  css('fieldset').styles(
    margin: Margin.zero,
  ),
  css('fieldset, legend').styles(
    padding: Padding.zero,
  ),
  css('menu, ol, ul').styles(
    listStyle: ListStyle.none,
    margin: Margin.zero,
    padding: Padding.zero,
  ),
  css('dialog').styles(
    padding: Padding.zero,
  ),
  css('textarea').styles(
    raw: {
      'resize': 'vertical',
    },
  ),
  css('input::placeholder, textarea::placeholder').styles(
    opacity: 1,
    color: Color('#9ca3af'),
  ),
  css('[role=button], button').styles(
    cursor: Cursor.pointer,
  ),
  css(':disabled').styles(
    cursor: Cursor.defaultCursor,
  ),
  css('audio, canvas, embed, iframe, img, object, svg, video').styles(
    display: Display.block,
    raw: {
      'vertical-align': 'middle',
    },
  ),
  css('img, video').styles(
    maxWidth: 100.percent,
    height: Unit.auto,
  ),

];
