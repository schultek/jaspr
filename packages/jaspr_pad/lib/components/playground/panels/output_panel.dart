import 'package:jaspr/jaspr.dart';

import '../output/execution_iframe.dart';

class OutputPanel extends StatelessComponent {
  const OutputPanel({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'div', id: 'output-panel', children: [
      ExecutionIFrame(),
    ]);
  }
}
