import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../constants/theme.dart';
import 'items/0_develop.dart';
import 'items/1_run.dart';
import 'items/2_integrate.dart';
import 'items/3_analyze.dart';

class DevExp extends StatelessComponent {
  const DevExp({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'devex', [
      span(classes: 'caption text-gradient', [.text('Developer Experience')]),
      h2([.text('The productivity of Dart'), br(), .text('brought to the Web')]),
      div(classes: 'devex-grid', [
        div([Develop(), Run()]),
        div([Integrate(), Analyze()]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('#devex', [
      css('&').styles(
        display: .flex,
        padding: .only(top: sectionPadding),
        flexDirection: .column,
        alignItems: .center,
        textAlign: .center,
      ),
      css('.devex-grid', [
        css('&').styles(
          display: .flex,
          maxWidth: maxContentWidth,
          padding: .symmetric(horizontal: contentPadding),
          margin: .only(top: 3.rem),
          flexDirection: .column,
          gap: .row(3.rem),
        ),
        css('& > div', [
          css('&').styles(
            display: .flex,
            flexDirection: .row,
            flexWrap: .wrap,
            gap: .all(3.rem),
          ),
          css('& > *').styles(flex: .new(grow: 1, shrink: 1, basis: 16.rem)),
          css('&:first-child > *:first-child').styles(flex: .basis(30.rem)),
          css('&:last-child > *:last-child').styles(flex: .basis(30.rem)),
        ]),
      ]),
    ]),
  ];
}
