import 'package:jaspr/jaspr.dart';

import '../../../constants/theme.dart';
import 'items/0_develop.dart';
import 'items/1_run.dart';
import 'items/2_integrate.dart';
import 'items/3_analyze.dart';

class DevExp extends StatelessComponent {
  const DevExp({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section(id: 'devex', [
      span(classes: 'caption text-gradient', [text('Developer Experience')]),
      h2([text('The productivity of Dart'), br(), text('brought to the Web')]),
      div(classes: 'devex-grid', [
        div([
          Develop(),
          Run(),
        ]),
        div([
          Integrate(),
          Analyze(),
        ]),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#devex', [
      css('&')
          .box(padding: EdgeInsets.only(top: sectionPadding))
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.center)
          .text(align: TextAlign.center),
      css('.devex-grid', [
        css('&')
            .box(
              maxWidth: maxContentWidth,
              margin: EdgeInsets.only(top: 3.rem),
              padding: EdgeInsets.symmetric(horizontal: contentPadding),
            )
            .flexbox(direction: FlexDirection.column, gap: Gap(row: 3.rem)),
        css('& > div', [
          css('&').flexbox(direction: FlexDirection.row, wrap: FlexWrap.wrap, gap: Gap.all(3.rem)),
          css('& > *').flexItem(flex: Flex(grow: 1, shrink: 1, basis: FlexBasis(16.rem))),
          css('&:first-child > *:first-child').raw({'flex-basis': '30rem'}),
          css('&:last-child > *:last-child').raw({'flex-basis': '30rem'}),
        ]),
      ])
    ]),
  ];
}
