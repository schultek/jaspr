import 'package:jaspr/jaspr.dart';

class HorizontalLine extends StatelessComponent {
  HorizontalLine();

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'hr');
  }
}
