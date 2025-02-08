import 'package:jaspr/jaspr.dart';

// Colors

const primaryDark = Color.hex('#09387e');
const primaryMid = Color.hex('#0066B4');
const primaryMidLow = Color.variable('--primaryMidLow');
const primaryLight = Color.hex('#40C4FF');

const primaryFaded = Color.variable('--primaryFaded');

final primaryGradient = 'linear-gradient(90deg, ${primaryDark.value}, ${primaryMid.value}, ${primaryLight.value})';

final textDim = Color.variable('--textDim');
final textDark = Color.variable('--textDark');
final textBlack = Color.variable('--textBlack');

final shadowColor1 = Color.variable('--shadowColor1');
final shadowColor2 = Color.variable('--shadowColor2');
final shadowColor3 = Color.variable('--shadowColor3');

final background = Color.variable('--background');
final backgroundFaded = Color.variable('--backgroundFaded');

final borderColor = Color.variable('--borderColor');
final borderColor2 = Color.variable('--borderColor2');

final surface = Color.variable('--surface');
final surfaceLow = Color.variable('--surfaceLow');
final surfaceLowest = Color.variable('--surfaceLowest');

final hoverOverlayColor = Color.variable('--hoverOverlayColor');

final lightTheme = {
  primaryMidLow: Color.hex('#004377'),
  primaryFaded: Color.hex('#0066b41e'),
  textDim: Color.hex('#777'),
  textDark: Color.hex('#555'),
  textBlack: Color.hex('#222'),
  shadowColor1: Color.hex('#0001'),
  shadowColor2: Color.hex('#0004'),
  shadowColor3: Color.hex('#0002'),
  background: Color.hex('#FFF'),
  backgroundFaded: Color.hex('#FFF9'),
  borderColor: Color.hex('#EEE'),
  borderColor2: Color.hex('#CCC'),
  surface: Color.hex('#F5F5F5'),
  surfaceLow: Color.hex('#F8F8F8'),
  surfaceLowest: Color.hex('#FCFCFC'),
  hoverOverlayColor: Color.hex('#0001'),
};

final darkTheme = {
  primaryMidLow: Color.hex('#007ad7'),
  primaryFaded: Color.hex('#6ad0ff1c'),
  textDim: Color.hex('#CCC'),
  textDark: Color.hex('#EEE'),
  textBlack: Color.hex('#F5F5F5'),
  shadowColor1: Color.hex('#0001'),
  shadowColor2: Color.hex('#0004'),
  shadowColor3: Color.hex('#0002'),
  background: Color.hex('#0d1117'),
  backgroundFaded: Color.hex('#0d111799'),
  borderColor: Color.hex('#1d1f25'),
  borderColor2: Color.hex('#292c35'),
  surface: Color.hex('#070c14'),
  surfaceLow: Color.hex('#161b1f'),
  surfaceLowest: Color.hex('#11141a'),
  hoverOverlayColor: Color.hex('#FFF1'),
};

// Typography

final monoFont = FontFamily.list([
  FontFamilies.uiMonospace,
  FontFamily('SFMono-Regular'),
  FontFamily('Menlo'),
  FontFamily('Monaco'),
  FontFamily('Consolas'),
  FontFamily('Liberation Mono'),
  FontFamily('Courier New'),
  FontFamilies.monospace
]);

final bodySmall = Styles.text(fontSize: 0.875.rem, fontWeight: FontWeight.w400, lineHeight: 1.3.em, color: textDim);
final bodyMedium = Styles.text(fontSize: 1.rem, fontWeight: FontWeight.w400, lineHeight: 1.6.em, color: textDark);
final bodyLarge = Styles.text(fontSize: 1.1.rem, fontWeight: FontWeight.w400, lineHeight: 1.7.em, color: textDark);
final caption = Styles.text(fontSize: 1.2.rem, fontWeight: FontWeight.w800, color: primaryMid);
final caption2 = Styles.text(fontSize: 0.8.rem, fontWeight: FontWeight.w800, color: primaryMid, letterSpacing: 0.08.em);
final heading1 = Styles.text(fontSize: 4.rem, fontWeight: FontWeight.w800, color: textBlack);
final heading2 = Styles.text(fontSize: 3.rem, fontWeight: FontWeight.w700, color: textBlack);
final heading3 = Styles.text(fontSize: 2.5.rem, fontWeight: FontWeight.w700, color: textBlack);
final heading4 = Styles.text(fontSize: 1.5.rem, fontWeight: FontWeight.w700, color: textBlack);
final heading5 = Styles.text(fontSize: 1.rem, fontWeight: FontWeight.w600, color: textBlack);

const maxContentWidth = Unit.rem(70);
const mobileBreakpoint = Unit.rem(40);
const smallMobileBreakpoint = Unit.rem(25);

const contentPadding = Unit.variable('--contentPadding');
const sectionPadding = Unit.variable('--sectionPadding');

@css
final root = [
  css.import('font/inter/inter.css'),
  css.import('font/lucide/lucide.css'),

  // Global
  css('html, body').box(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
  css('html').background(color: background),

  // Theme

  css(':root').raw({
    for (final color in lightTheme.keys) color.value.substring(4, color.value.length - 1): lightTheme[color]!.value,
    '--contentPadding': '4rem',
    '--sectionPadding': '16rem',
  }),

  css(':root.dark').raw({
    for (final color in darkTheme.keys) color.value.substring(4, color.value.length - 1): darkTheme[color]!.value,
  }),

  css.media(MediaQuery.all(maxWidth: mobileBreakpoint), [
    css(':root').raw({
      '--contentPadding': '2rem',
      '--sectionPadding': '8rem',
    }),
  ]),

  css.media(MediaQuery.all(maxWidth: smallMobileBreakpoint), [
    css(':root').raw({
      '--contentPadding': '1rem',
      '--sectionPadding': '4rem',
    }),
  ]),

  // Typography
  css('.caption').combine(caption),
  css('.caption2').combine(caption2),
  css('p').combine(bodyMedium),
  css('h1').combine(heading1).box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.rem)),
  css('h2').combine(heading2).box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.em)),
  css('h3').combine(heading3).box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.em)),
  css('h4').combine(heading4).box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.em)),
  css('h5').combine(heading5).box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.em)),

  css.media(MediaQuery.all(maxWidth: mobileBreakpoint), [
    css('h1').text(fontSize: 2.6.rem),
    css('h2').text(fontSize: 1.8.rem),
    css('h3').text(fontSize: 1.8.rem),
    css('h4').text(fontSize: 1.2.rem),
  ]),

  // Common
  css('.actions').flexbox(
    direction: FlexDirection.row,
    alignItems: AlignItems.center,
    gap: Gap.all(.8.em),
    wrap: FlexWrap.wrap,
  ),
  css('.text-gradient').raw({
    'background': primaryGradient,
    '-webkit-background-clip': 'text',
    '-webkit-text-fill-color': 'transparent',
  }),
  css('a').text(decoration: TextDecoration.none, color: textDark),
  css('b').text(fontWeight: FontWeight.w500),

  css('code, pre, .mono').text(
    fontFamily: monoFont,
    fontSize: 0.875.rem,
    lineHeight: 1.4.em,
  ),

  // Animated underline
  css('.animated-underline', [
    css('&')
        .raw({'background-image': 'linear-gradient(to right, currentColor, currentColor)'})
        .background(
          position: BackgroundPosition(offsetX: Unit.zero, offsetY: 100.percent),
          repeat: BackgroundRepeat.noRepeat,
          size: BackgroundSize.sides(Unit.zero, 1.5.px),
        )
        .box(transition: Transition('background-size', duration: 300, curve: Curve.easeInOut)),
    css('&:hover').background(size: BackgroundSize.sides(100.percent, 1.5.px)),
  ]),
];
