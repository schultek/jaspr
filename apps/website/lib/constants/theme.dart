import 'package:jaspr/jaspr.dart';

// Colors

const primaryDark = Color.hex('#072F69');
const primaryMid = Color.hex('#0066B4');
const primaryLight = Color.hex('#6AD1FF');

final primaryGradient = 'linear-gradient(90deg, ${primaryDark.value}, ${primaryMid.value}, ${primaryLight.value})';

final textDark = Color.hex('#333');

// Typography

final baseFont = Styles.text(
    fontFamily: FontFamily.list([FontFamily('Inter'), FontFamilies.sansSerif]), fontWeight: FontWeight.w400);

final bodySmall = Styles.text(fontSize: 1.rem, fontWeight: FontWeight.w400, color: textDark);
final bodyLarge = Styles.text(fontSize: 1.1.rem, fontWeight: FontWeight.w400, lineHeight: 1.7.em, color: textDark);
final caption = Styles.text(fontSize: 1.5.rem, fontWeight: FontWeight.w800, color: primaryMid);
final heading2 = Styles.text(fontSize: 3.5.rem, fontWeight: FontWeight.w700);
final heading3 = Styles.text(fontSize: 2.5.rem, fontWeight: FontWeight.w700);

@css
final root = [
  css.import('font/inter.css'),
  css.import('https://unpkg.com/lucide-static@latest/font/lucide.css'),

  // Global
  css(':root').combine(baseFont),
  css.supports('(font-variation-settings: normal)', [
    css(':root').combine(baseFont).raw({'font-optical-sizing': 'auto'}),
  ]),
  css('html, body').box(margin: EdgeInsets.zero, padding: EdgeInsets.zero).raw({'scroll-behavior': 'smooth'}),

  // Typography
  css('.caption').combine(caption),
  css('p').combine(bodySmall),
  css('h2').combine(heading2).box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.em)),
  css('h3').combine(heading3).box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.em)),

  // Common
  css('.actions').flexbox(direction: FlexDirection.row, gap: Gap(column: .8.em)),
  css('.text-gradient').raw({
    'background': primaryGradient,
    '-webkit-background-clip': 'text',
    '-webkit-text-fill-color': 'transparent',
  }),
];
