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
      css('&').styles(
        padding: Padding.only(top: sectionPadding),
        display: Display.flex,
        flexDirection: FlexDirection.column,
        alignItems: AlignItems.center,
        textAlign: TextAlign.center,
      ),
      css('.devex-grid', [
        css('&').styles(
          maxWidth: maxContentWidth,
          margin: Margin.only(top: 3.rem),
          padding: Padding.symmetric(horizontal: contentPadding),
          display: Display.flex,
          flexDirection: FlexDirection.column,
          gap: Gap(row: 3.rem),
        ),
        css('& > div', [
          css('&').styles(
            display: Display.flex,
            flexDirection: FlexDirection.row,
            flexWrap: FlexWrap.wrap,
            gap: Gap.all(3.rem),
          ),
          css('& > *').styles(
            flex: Flex(grow: 1, shrink: 1, basis: FlexBasis(16.rem)),
          ),
          css('&:first-child > *:first-child').styles(flex: Flex(basis: FlexBasis(30.rem))),
          css('&:last-child > *:last-child').styles(flex: Flex(basis: FlexBasis(30.rem))),
        ]),
      ])
    ]),
  ];
}
