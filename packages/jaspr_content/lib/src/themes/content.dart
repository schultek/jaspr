import 'package:jaspr/jaspr.dart';

import 'colors.dart';

final List<StyleRule> _contentStyles = [
  css('.content', [
    css('&').styles(
      color: Color.variable('--content-body'),
      maxWidth: Unit.expression('65ch'),
    ),
    css('a').styles(
      color: Color.variable('--content-links'),
      textDecoration: TextDecoration(line: TextDecorationLine.underline),
      fontWeight: FontWeight.w500,
    ),
    css('strong').styles(
      color: Color.variable('--content-bold'),
      fontWeight: FontWeight.w600,
    ),
    css('a strong').styles(
      color: Color.inherit,
    ),
    css('blockquote strong').styles(
      color: Color.inherit,
    ),
    css('thead th strong').styles(
      color: Color.inherit,
    ),
    css('ol').styles(
      listStyle: ListStyle.decimal,
    ),
    css('ol[type="A"]').styles(
      listStyle: ListStyle.upperAlpha,
    ),
    css('ol[type="a"]').styles(
      listStyle: ListStyle.lowerAlpha,
    ),
    css('ol[type="A" s]').styles(
      listStyle: ListStyle.upperAlpha,
    ),
    css('ol[type="a" s]').styles(
      listStyle: ListStyle.lowerAlpha,
    ),
    css('ol[type="I"]').styles(
      listStyle: ListStyle.upperRoman,
    ),
    css('ol[type="i"]').styles(
      listStyle: ListStyle.lowerRoman,
    ),
    css('ol[type="I" s]').styles(
      listStyle: ListStyle.upperRoman,
    ),
    css('ol[type="i" s]').styles(
      listStyle: ListStyle.lowerRoman,
    ),
    css('ol[type="1"]').styles(
      listStyle: ListStyle.decimal,
    ),
    css('ul').styles(
      listStyle: ListStyle.disc,
    ),
    css('ol > li::marker').styles(
      fontWeight: FontWeight.w400,
      color: Color.variable('--content-counters'),
    ),
    css('ul > li::marker').styles(
      color: Color.variable('--content-bullets'),
    ),
    css('dt').styles(
      color: Color.variable('--content-headings'),
      fontWeight: FontWeight.w600,
    ),
    css('hr').styles(
      border: Border(color: Color.variable('--content-hr')),
      raw: {
        'border-top-width': '1px',
      },
    ),
    css('blockquote').styles(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      color: Color.variable('--content-quotes'),
      raw: {
        'border-inline-start-width': '0.25rem',
        'border-inline-start-color': 'var(--content-quote-borders)',
        'quotes': '"\\201C""\\201D""\\2018""\\2019"',
      },
    ),
    css('blockquote p:first-of-type::before').styles(
      raw: {
        'content': 'open-quote',
      },
    ),
    css('blockquote p:last-of-type::after').styles(
      raw: {
        'content': 'close-quote',
      },
    ),
    css('h1').styles(
      color: Color.variable('--content-headings'),
      fontWeight: FontWeight.w800,
    ),
    css('h1 strong').styles(
      fontWeight: FontWeight.w900,
      color: Color.inherit,
    ),
    css('h2').styles(
      color: Color.variable('--content-headings'),
      fontWeight: FontWeight.w700,
    ),
    css('h2 strong').styles(
      fontWeight: FontWeight.w800,
      color: Color.inherit,
    ),
    css('h3').styles(
      color: Color.variable('--content-headings'),
      fontWeight: FontWeight.w600,
    ),
    css('h3 strong').styles(
      fontWeight: FontWeight.w700,
      color: Color.inherit,
    ),
    css('h4').styles(
      color: Color.variable('--content-headings'),
      fontWeight: FontWeight.w600,
    ),
    css('h4 strong').styles(
      fontWeight: FontWeight.w700,
      color: Color.inherit,
    ),
    css('picture').styles(
      display: Display.block,
    ),
    css('kbd').styles(
      fontWeight: FontWeight.w500,
      fontFamily: FontFamily.inherit,
      color: Color.variable('--content-kbd'),
    ),
    css('code').styles(
      color: Color.variable('--content-code'),
      fontWeight: FontWeight.w600,
    ),
    css('code::before').styles(
      content: '`',
    ),
    css('code::after').styles(
      content: '`',
    ),
    css('a code').styles(
      color: Color.inherit,
    ),
    css('h1 code').styles(
      color: Color.inherit,
    ),
    css('h2 code').styles(
      color: Color.inherit,
    ),
    css('h3 code').styles(
      color: Color.inherit,
    ),
    css('h4 code').styles(
      color: Color.inherit,
    ),
    css('blockquote code').styles(
      color: Color.inherit,
    ),
    css('thead th code').styles(
      color: Color.inherit,
    ),
    css('pre').styles(
      color: Color.variable('--content-pre-code'),
      backgroundColor: Color.variable('--content-pre-bg'),
      overflow: Overflow.only(x: Overflow.auto),
      fontWeight: FontWeight.w400,
    ),
    css('pre code').styles(
      backgroundColor: Colors.transparent,
      border: Border(width: Unit.zero),
      radius: BorderRadius.circular(Unit.zero),
      padding: Padding.zero,
      fontWeight: FontWeight.inherit,
      color: Color.inherit,
      fontSize: Unit.inherit,
      fontFamily: FontFamily.inherit,
      lineHeight: Unit.inherit,
    ),
    css('pre code::before').styles(
      raw: {
        'content': 'none',
      },
    ),
    css('pre code::after').styles(
      raw: {
        'content': 'none',
      },
    ),
    css('table').styles(
      width: Unit.percent(100),
      margin: Margin.symmetric(vertical: 2.em),
      raw: {
        'table-layout': 'auto',
      },
    ),
    css('thead').styles(
      border: Border.only(
        bottom: BorderSide(
          width: 1.px,
          color: Color.variable('--content-th-borders'),
        ),
      ),
    ),
    css('thead th').styles(
      color: Color.variable('--content-headings'),
      fontWeight: FontWeight.w600,
      raw: {
        'vertical-align': 'bottom',
      },
    ),
    css('tbody tr').styles(
      border: Border.only(
        bottom: BorderSide(
          width: 1.px,
          color: Color.variable('--content-td-borders'),
        ),
      ),
    ),
    css('tbody tr:last-child').styles(
      border: Border.only(bottom: BorderSide(width: Unit.zero)),
    ),
    css('tbody td').styles(
      raw: {
        'vertical-align': 'baseline',
      },
    ),
    css('tfoot').styles(
      border: Border.only(
        top: BorderSide(
          width: 1.px,
          color: Color.variable('--content-th-borders'),
        ),
      ),
    ),
    css('tfoot td').styles(
      raw: {
        'vertical-align': 'top',
      },
    ),
    css('th, td').styles(
      raw: {
        'text-align': 'start',
      },
    ),
    css('figcaption').styles(
      color: Color.variable('--content-captions'),
    ),
  ]),
];

final _contentColorsGray = {
  '--content-body': colors.gray.$700,
  '--content-headings': colors.gray.$900,
  '--content-lead': colors.gray.$600,
  '--content-links': colors.gray.$900,
  '--content-bold': colors.gray.$900,
  '--content-counters': colors.gray.$500,
  '--content-bullets': colors.gray.$300,
  '--content-hr': colors.gray.$200,
  '--content-quotes': colors.gray.$900,
  '--content-quote-borders': colors.gray.$200,
  '--content-captions': colors.gray.$500,
  '--content-kbd': colors.gray.$900,
  '--content-kbd-shadows': colors.gray.$900,
  '--content-code': colors.gray.$900,
  '--content-pre-code': colors.gray.$200,
  '--content-pre-bg': colors.gray.$800,
  '--content-th-borders': colors.gray.$300,
  '--content-td-borders': colors.gray.$200,
};

final List<StyleRule> contentGray = [
 css('.content').styles(raw: {
    ..._contentColorsGray.map((k, v) => MapEntry(k, v.value)),
  }),
];

final List<StyleRule> contentBase = [
  ..._contentStyles,
  css('.content', [
    css('&').styles(
      fontSize: 1.rem,
      lineHeight: 1.75.em,
    ),
    css('p').styles(
      margin: Margin.only(top: 1.25.em, bottom: 1.25.em),
    ),
    css('blockquote').styles(
      margin: Margin.only(top: 1.6.em, bottom: 1.6.em),
      padding: Padding.only(left: 1.em),
    ),
    css('h1').styles(
      fontSize: 2.25.em,
      margin: Margin.only(top: Unit.zero, bottom: 0.88.em),
      lineHeight: 1.11.em,
    ),
    css('h2').styles(
      fontSize: 1.5.em,
      margin: Margin.only(top: 1.5.em, bottom: 1.em),
      lineHeight: 1.33.em,
    ),
    css('h3').styles(
      fontSize: 1.25.em,
      margin: Margin.only(top: 1.6.em, bottom: 0.6.em),
      lineHeight: 1.6.em,
    ),
    css('h4').styles(
      margin: Margin.only(top: 2.em, bottom: 0.5.em),
      lineHeight: 1.5.em,
    ),
    css('img').styles(
      margin: Margin.symmetric(vertical: 2.em),
    ),
    css('picture').styles(
      margin: Margin.symmetric(vertical: 2.em),
    ),
    css('picture > img').styles(
      margin: Margin.symmetric(vertical: Unit.zero),
    ),
    css('video').styles(
      margin: Margin.symmetric(vertical: 2.em),
    ),
    css('kbd').styles(
      fontSize: 0.875.em,
      radius: BorderRadius.circular(0.3125.rem),
      padding: Padding.only(
        top: 0.1875.rem,
        right: 0.375.rem,
        bottom: 0.1875.rem,
        left: 0.375.rem,
      ),
    ),
    css('code').styles(
      fontSize: 0.875.em,
    ),
    css('h2 code').styles(
      fontSize: 0.875.em,
    ),
    css('h3 code').styles(
      fontSize: 0.9.em,
    ),
    css('pre').styles(
      fontSize: 0.875.em,
      lineHeight: 1.71.em,
      margin: Margin.only(top: 1.71.em, bottom: 1.71.em),
      radius: BorderRadius.circular(0.375.rem),
      padding: Padding.only(
        top: 0.857.em,
        right: 1.14.em,
        bottom: 0.857.em,
        left: 1.14.em,
      ),
    ),
    css('ol').styles(
      margin: Margin.symmetric(vertical: 1.25.em),
      padding: Padding.only(left: 1.625.em),
    ),
    css('ul').styles(
      margin: Margin.symmetric(vertical: 1.25.em),
      padding: Padding.only(left: 1.625.em),
    ),
    css('li').styles(
      margin: Margin.symmetric(vertical: 0.5.em),
    ),
    css('ol > li').styles(
      padding: Padding.only(left: 0.375.em),
    ),
    css('ul > li').styles(
      padding: Padding.only(left: 0.375.em),
    ),
    css('> ul > li p').styles(
      margin: Margin.symmetric(vertical: 0.75.em),
    ),
    css('> ul > li > p:first-child').styles(
      margin: Margin.only(top: 1.25.em),
    ),
    css('> ul > li > p:last-child').styles(
      margin: Margin.only(bottom: 1.25.em),
    ),
    css('> ol > li > p:first-child').styles(
      margin: Margin.only(top: 1.25.em),
    ),
    css('> ol > li > p:last-child').styles(
      margin: Margin.only(bottom: 1.25.em),
    ),
    css('ul ul, ul ol, ol ul, ol ol').styles(
      margin: Margin.symmetric(vertical: 0.75.em),
    ),
    css('dl').styles(
      margin: Margin.symmetric(vertical: 1.25.em),
    ),
    css('dt').styles(
      margin: Margin.only(top: 1.25.em),
    ),
    css('dd').styles(
      margin: Margin.only(top: 0.5.em),
      padding: Padding.only(left: 1.625.em),
    ),
    css('hr').styles(
      margin: Margin.symmetric(vertical: 3.em),
    ),
    css('hr + *').styles(
      margin: Margin.only(top: Unit.zero),
    ),
    css('h2 + *').styles(
      margin: Margin.only(top: Unit.zero),
    ),
    css('h3 + *').styles(
      margin: Margin.only(top: Unit.zero),
    ),
    css('h4 + *').styles(
      margin: Margin.only(top: Unit.zero),
    ),
    css('table').styles(
      fontSize: 0.875.em,
      lineHeight: 1.71.em,
    ),
    css('thead th').styles(
      padding: Padding.only(
        right: 0.57.em,
        bottom: 0.57.em,
        left: 0.57.em,
      ),
    ),
    css('thead th:first-child').styles(
      padding: Padding.only(left: Unit.zero),
    ),
    css('thead th:last-child').styles(
      padding: Padding.only(right: Unit.zero),
    ),
    css('tbody td, tfoot td').styles(
      padding: Padding.only(
        top: 0.57.em,
        right: 0.57.em,
        bottom: 0.57.em,
        left: 0.57.em,
      ),
    ),
    css('tbody td:first-child, tfoot td:first-child').styles(
      padding: Padding.only(left: Unit.zero),
    ),
    css('tbody td:last-child, tfoot td:last-child').styles(
      padding: Padding.only(right: Unit.zero),
    ),
    css('figure').styles(
      margin: Margin.symmetric(vertical: 2.em),
    ),
    css('figure > *').styles(
      margin: Margin.symmetric(vertical: Unit.zero),
    ),
    css('figcaption').styles(
      fontSize: 0.875.em,
      lineHeight: 1.42.em,
      margin: Margin.only(top: 0.857.em),
    ),
    css('> :first-child').styles(
      margin: Margin.only(top: Unit.zero),
    ),
    css('> :last-child').styles(
      margin: Margin.only(bottom: Unit.zero),
    ),
  ])
];

/*
{
  fontSize: rem(16),
  lineHeight: round(28 / 16),
  p: {
    marginTop: em(20, 16),
    marginBottom: em(20, 16),
  },
  '[class~="lead"]': {
    fontSize: em(20, 16),
    lineHeight: round(32 / 20),
    marginTop: em(24, 20),
    marginBottom: em(24, 20),
  },
  blockquote: {
    marginTop: em(32, 20),
    marginBottom: em(32, 20),
    paddingInlineStart: em(20, 20),
  },
  h1: {
    fontSize: em(36, 16),
    marginTop: '0',
    marginBottom: em(32, 36),
    lineHeight: round(40 / 36),
  },
  h2: {
    fontSize: em(24, 16),
    marginTop: em(48, 24),
    marginBottom: em(24, 24),
    lineHeight: round(32 / 24),
  },
  h3: {
    fontSize: em(20, 16),
    marginTop: em(32, 20),
    marginBottom: em(12, 20),
    lineHeight: round(32 / 20),
  },
  h4: {
    marginTop: em(24, 16),
    marginBottom: em(8, 16),
    lineHeight: round(24 / 16),
  },
  img: {
    marginTop: em(32, 16),
    marginBottom: em(32, 16),
  },
  picture: {
    marginTop: em(32, 16),
    marginBottom: em(32, 16),
  },
  'picture > img': {
    marginTop: '0',
    marginBottom: '0',
  },
  video: {
    marginTop: em(32, 16),
    marginBottom: em(32, 16),
  },
  kbd: {
    fontSize: em(14, 16),
    borderRadius: rem(5),
    paddingTop: em(3, 16),
    paddingInlineEnd: em(6, 16),
    paddingBottom: em(3, 16),
    paddingInlineStart: em(6, 16),
  },
  code: {
    fontSize: em(14, 16),
  },
  'h2 code': {
    fontSize: em(21, 24),
  },
  'h3 code': {
    fontSize: em(18, 20),
  },
  pre: {
    fontSize: em(14, 16),
    lineHeight: round(24 / 14),
    marginTop: em(24, 14),
    marginBottom: em(24, 14),
    borderRadius: rem(6),
    paddingTop: em(12, 14),
    paddingInlineEnd: em(16, 14),
    paddingBottom: em(12, 14),
    paddingInlineStart: em(16, 14),
  },
  ol: {
    marginTop: em(20, 16),
    marginBottom: em(20, 16),
    paddingInlineStart: em(26, 16),
  },
  ul: {
    marginTop: em(20, 16),
    marginBottom: em(20, 16),
    paddingInlineStart: em(26, 16),
  },
  li: {
    marginTop: em(8, 16),
    marginBottom: em(8, 16),
  },
  'ol > li': {
    paddingInlineStart: em(6, 16),
  },
  'ul > li': {
    paddingInlineStart: em(6, 16),
  },
  '> ul > li p': {
    marginTop: em(12, 16),
    marginBottom: em(12, 16),
  },
  '> ul > li > p:first-child': {
    marginTop: em(20, 16),
  },
  '> ul > li > p:last-child': {
    marginBottom: em(20, 16),
  },
  '> ol > li > p:first-child': {
    marginTop: em(20, 16),
  },
  '> ol > li > p:last-child': {
    marginBottom: em(20, 16),
  },
  'ul ul, ul ol, ol ul, ol ol': {
    marginTop: em(12, 16),
    marginBottom: em(12, 16),
  },
  dl: {
    marginTop: em(20, 16),
    marginBottom: em(20, 16),
  },
  dt: {
    marginTop: em(20, 16),
  },
  dd: {
    marginTop: em(8, 16),
    paddingInlineStart: em(26, 16),
  },
  hr: {
    marginTop: em(48, 16),
    marginBottom: em(48, 16),
  },
  'hr + *': {
    marginTop: '0',
  },
  'h2 + *': {
    marginTop: '0',
  },
  'h3 + *': {
    marginTop: '0',
  },
  'h4 + *': {
    marginTop: '0',
  },
  table: {
    fontSize: em(14, 16),
    lineHeight: round(24 / 14),
  },
  'thead th': {
    paddingInlineEnd: em(8, 14),
    paddingBottom: em(8, 14),
    paddingInlineStart: em(8, 14),
  },
  'thead th:first-child': {
    paddingInlineStart: '0',
  },
  'thead th:last-child': {
    paddingInlineEnd: '0',
  },
  'tbody td, tfoot td': {
    paddingTop: em(8, 14),
    paddingInlineEnd: em(8, 14),
    paddingBottom: em(8, 14),
    paddingInlineStart: em(8, 14),
  },
  'tbody td:first-child, tfoot td:first-child': {
    paddingInlineStart: '0',
  },
  'tbody td:last-child, tfoot td:last-child': {
    paddingInlineEnd: '0',
  },
  figure: {
    marginTop: em(32, 16),
    marginBottom: em(32, 16),
  },
  'figure > *': {
    marginTop: '0',
    marginBottom: '0',
  },
  figcaption: {
    fontSize: em(14, 16),
    lineHeight: round(20 / 14),
    marginTop: em(12, 14),
  },
},
{
  '> :first-child': {
    marginTop: '0',
  },
  '> :last-child': {
    marginBottom: '0',
  },
},
*/