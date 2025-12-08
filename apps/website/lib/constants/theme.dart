import 'package:jaspr/dom.dart';

// Colors

const primaryDark = Color('#09387e');
const primaryMid = Color('#0066B4');
const primaryMidLow = Color.variable('--primaryMidLow');
const primaryLight = Color('#40C4FF');

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
  primaryMidLow: Color('#004377'),
  primaryFaded: Color('#0066b41e'),
  textDim: Color('#777'),
  textDark: Color('#555'),
  textBlack: Color('#222'),
  shadowColor1: Color('#0001'),
  shadowColor2: Color('#0004'),
  shadowColor3: Color('#0002'),
  background: Color('#FFF'),
  backgroundFaded: Color('#FFF9'),
  borderColor: Color('#EEE'),
  borderColor2: Color('#CCC'),
  surface: Color('#F5F5F5'),
  surfaceLow: Color('#F8F8F8'),
  surfaceLowest: Color('#FCFCFC'),
  hoverOverlayColor: Color('#0001'),
};

final darkTheme = {
  primaryMidLow: Color('#007ad7'),
  primaryFaded: Color('#6ad0ff1c'),
  textDim: Color('#CCC'),
  textDark: Color('#EEE'),
  textBlack: Color('#F5F5F5'),
  shadowColor1: Color('#0001'),
  shadowColor2: Color('#0004'),
  shadowColor3: Color('#0002'),
  background: Color('#0d1117'),
  backgroundFaded: Color('#0d111799'),
  borderColor: Color('#1d1f25'),
  borderColor2: Color('#292c35'),
  surface: Color('#070c14'),
  surfaceLow: Color('#161b1f'),
  surfaceLowest: Color('#11141a'),
  hoverOverlayColor: Color('#FFF1'),
};

// Typography

final bodySmall = Styles(color: textDim, fontSize: 0.875.rem, fontWeight: .w400, lineHeight: 1.3.em);
final bodyMedium = Styles(color: textDark, fontSize: 1.rem, fontWeight: .w400, lineHeight: 1.6.em);
final bodyLarge = Styles(color: textDark, fontSize: 1.1.rem, fontWeight: .w400, lineHeight: 1.7.em);
final caption = Styles(color: primaryMid, fontSize: 1.2.rem, fontWeight: .w800);
final caption2 = Styles(color: primaryMid, fontSize: 0.8.rem, fontWeight: .w800, letterSpacing: 0.08.em);
final heading1 = Styles(color: textBlack, fontSize: 4.rem, fontWeight: .w800);
final heading2 = Styles(color: textBlack, fontSize: 3.rem, fontWeight: .w700);
final heading3 = Styles(color: textBlack, fontSize: 2.5.rem, fontWeight: .w700);
final heading4 = Styles(color: textBlack, fontSize: 1.5.rem, fontWeight: .w700);
final heading5 = Styles(color: textBlack, fontSize: 1.rem, fontWeight: .w600);

const maxContentWidth = Unit.rem(70);
const mobileBreakpoint = Unit.rem(40);
const smallMobileBreakpoint = Unit.rem(25);

const contentPadding = Unit.variable('--contentPadding');
const sectionPadding = Unit.variable('--sectionPadding');

@css
List<StyleRule> get root => [
  css.import('font/lucide/lucide.css'),

  // Global
  css('html, body').styles(padding: .zero, margin: .zero),
  css('html').styles(
    fontFamily: .list([FontFamilies.uiSansSerif, FontFamilies.systemUi, FontFamilies.sansSerif]),
    backgroundColor: background,
  ),

  // Theme
  css(':root').styles(
    raw: {
      for (final color in lightTheme.keys) color.value.substring(4, color.value.length - 1): lightTheme[color]!.value,
      '--contentPadding': '4rem',
      '--sectionPadding': '16rem',
    },
  ),

  css(':root.dark').styles(
    raw: {
      for (final color in darkTheme.keys) color.value.substring(4, color.value.length - 1): darkTheme[color]!.value,
    },
  ),

  css.media(.all(maxWidth: mobileBreakpoint), [
    css(':root').styles(raw: {'--contentPadding': '2rem', '--sectionPadding': '8rem'}),
  ]),

  css.media(.all(maxWidth: smallMobileBreakpoint), [
    css(':root').styles(raw: {'--contentPadding': '1rem', '--sectionPadding': '4rem'}),
  ]),

  // Typography
  css('.caption').combine(caption),
  css('.caption2').combine(caption2),
  css('p').combine(bodyMedium),
  css('h1')
      .combine(heading1)
      .styles(
        margin: .only(top: .zero, bottom: 0.1.rem),
      ),
  css('h2')
      .combine(heading2)
      .styles(
        margin: .only(top: .zero, bottom: 0.1.em),
      ),
  css('h3')
      .combine(heading3)
      .styles(
        margin: .only(top: .zero, bottom: 0.1.em),
      ),
  css('h4')
      .combine(heading4)
      .styles(
        margin: .only(top: .zero, bottom: 0.1.em),
      ),
  css('h5')
      .combine(heading5)
      .styles(
        margin: .only(top: .zero, bottom: 0.1.em),
      ),

  css.media(.all(maxWidth: mobileBreakpoint), [
    css('h1').styles(fontSize: 2.6.rem),
    css('h2').styles(fontSize: 1.8.rem),
    css('h3').styles(fontSize: 1.8.rem),
    css('h4').styles(fontSize: 1.2.rem),
  ]),

  // Common
  css('.actions').styles(
    display: .flex,
    flexDirection: .row,
    flexWrap: .wrap,
    alignItems: .center,
    gap: .all(.8.em),
  ),
  css('.text-gradient').styles(
    raw: {'background': primaryGradient, '-webkit-background-clip': 'text', '-webkit-text-fill-color': 'transparent'},
  ),
  css('a').styles(color: textDark, textDecoration: .none),
  css('b').styles(fontWeight: .w500),

  css('code, pre, .mono').styles(
    fontFamily: .list([
      FontFamilies.uiMonospace,
      FontFamily('SFMono-Regular'),
      FontFamily('Menlo'),
      FontFamily('Monaco'),
      FontFamily('Consolas'),
      FontFamily('Liberation Mono'),
      FontFamily('Courier New'),
      FontFamilies.monospace,
    ]),
    fontSize: 0.875.rem,
    lineHeight: 1.4.em,
    raw: {'-webkit-text-size-adjust': '100%'},
  ),

  // Animated underline
  css('.animated-underline', [
    css('&').styles(
      transition: .new('background-size', duration: 300.ms, curve: .easeInOut),
      backgroundPosition: .new(offsetX: .zero, offsetY: 100.percent),
      backgroundRepeat: .noRepeat,
      backgroundSize: .sides(.zero, 1.5.px),
      raw: {'background-image': 'linear-gradient(to right, currentColor, currentColor)'},
    ),
    css('&:hover').styles(backgroundSize: .sides(100.percent, 1.5.px)),
  ]),
];
