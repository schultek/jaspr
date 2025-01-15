// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';

class Meet extends StatelessComponent {
  const Meet({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section(id: 'meet', []);
  }

  @css
  static final List<StyleRule> styles = [
    css('#meet').box(minHeight: 100.vh),
  ];
}
