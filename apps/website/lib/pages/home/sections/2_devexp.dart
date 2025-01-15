// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';

class DevExp extends StatelessComponent {
  const DevExp({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section(id: 'devexp', [
      span(classes: 'caption text-gradient', [text('Developer Experience')]),
      h2([text('The productivity of Dart'), br(), text('brought to the Web')]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#devexp', [
      css('&')
          .box(padding: EdgeInsets.only(top: 2.rem))
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.center)
          .text(align: TextAlign.center),
    ]),
  ];
}
