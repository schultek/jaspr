part of 'content.dart';

class ContentLayout {
  const ContentLayout({
    required this.styles,
    required this.rules,
  });

  static final ContentLayout base = _baseContentLayout;

  final Styles styles;
  final List<StyleRule> rules;
}

extension on ContentLayout {
  StyleRule build() {
    return css('.content', [
      css('&').styles(
          color: ContentTheme.text,
          maxWidth: Unit.expression('65ch'),
        )
        .combine(styles),
      ..._scopeContent([
        ..._contentStyles,
        ...rules,
      ]),
    ]);
  }
}


List<StyleRule> _scopeContent(List<StyleRule> rules) {
  return rules.expand((rule) => rule.resolve('')).map((rule) {
    if (rule is BlockStyleRule) {
      return BlockStyleRule(
        selector: Selector(
            ':where(${rule.selector.selector}):not(:where([class~=not-content],[class~=not-content] *))'),
        styles: rule.styles,
      );
    }
    return rule;
  }).toList();
}

final List<StyleRule> _contentStyles = [
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
];
