import 'package:jaspr/jaspr.dart';

// Colors

const primaryDark = Color.hex('#072F69');
const primaryMid = Color.hex('#0066B4');
const primaryLight = Color.hex('#6AD1FF');

final primaryGradient = 'linear-gradient(90deg, ${primaryDark.value}, ${primaryMid.value}, ${primaryLight.value})';

final textDim = Color.hex('#666');
final textDark = Color.hex('#333');
final textBlack = Color.hex('#222');

// Typography

final baseFont = Styles.text(
    fontFamily: FontFamily.list([FontFamily('Inter'), FontFamilies.sansSerif]), fontWeight: FontWeight.w400);

final bodySmall = Styles.text(fontSize: 0.9.rem, fontWeight: FontWeight.w400, lineHeight: 1.4.em, color: textDim);
final bodyMedium = Styles.text(fontSize: 1.rem, fontWeight: FontWeight.w400, lineHeight: 1.4.em, color: textDark);
final bodyLarge = Styles.text(fontSize: 1.1.rem, fontWeight: FontWeight.w400, lineHeight: 1.7.em, color: textDark);
final caption = Styles.text(fontSize: 1.2.rem, fontWeight: FontWeight.w800, color: primaryMid);
final caption2 = Styles.text(fontSize: 0.8.rem, fontWeight: FontWeight.w800, color: primaryMid, letterSpacing: 0.08.em);
final heading2 = Styles.text(fontSize: 3.rem, fontWeight: FontWeight.w700, color: textBlack);
final heading3 = Styles.text(fontSize: 2.5.rem, fontWeight: FontWeight.w700, color: textBlack);
final heading4 = Styles.text(fontSize: 1.5.rem, fontWeight: FontWeight.w700, color: textBlack);
final heading5 = Styles.text(fontSize: 1.rem, fontWeight: FontWeight.w600, color: textDark);

@css
final root = [
  css.import('font/inter.css'),
  css.import('https://unpkg.com/lucide-static@latest/font/lucide.css'),

  // Global
  css(':root').combine(baseFont),
  css.supports('(font-variation-settings: normal)', [
    css(':root').combine(baseFont).raw({'font-optical-sizing': 'auto'}),
  ]),
  css('html, body').box(margin: EdgeInsets.zero, padding: EdgeInsets.zero),

  // Typography
  css('.caption').combine(caption),
  css('.caption2').combine(caption2),
  css('p').combine(bodyMedium),
  css('h2').combine(heading2).box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.em)),
  css('h3').combine(heading3).box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.em)),
  css('h4').combine(heading4).box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.em)),
  css('h5').combine(heading5).box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.em)),

  // Common
  css('.actions').flexbox(direction: FlexDirection.row, gap: Gap(column: .8.em)),
  css('.text-gradient').raw({
    'background': primaryGradient,
    '-webkit-background-clip': 'text',
    '-webkit-text-fill-color': 'transparent',
  }),
  css('a').text(decoration: TextDecoration.none, color: textDark),
  css('a:visited').text(color: textDark),
  css('b').text(fontWeight: FontWeight.w500),

  css('code, pre, .mono').text(
    fontFamily: FontFamily.list([FontFamilies.uiMonospace, FontFamily('SFMono-Regular'), FontFamily('Menlo'), FontFamily('Monaco'), FontFamily('Consolas'), FontFamily('Liberation Mono'), FontFamily('Courier New'), FontFamilies.monospace]),
    fontSize: 1.em,
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
        .box(transition: Transition('background-size', duration: 500, curve: Curve.easeInOut)),
    css('&:hover').background(size: BackgroundSize.sides(100.percent, 1.5.px)),
  ]),
];
