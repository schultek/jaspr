import 'package:jaspr/jaspr.dart';
import 'package:jaspr/ui.dart';

class Size extends StatelessComponent {
  final String width;
  final String height;
  final Component? child;

  const Size({this.width = "100%", this.height = "100%", this.child});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DivElement(
      style: MultipleStyle(styles: [
        Style('width', width),
        Style('height', height),
      ]),
      child: child,
    );
  }
}
