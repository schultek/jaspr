import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/elements/div.dart';

class Size extends StatelessComponent {
  final String width;
  final String height;
  final Component? child;

  Size({this.width = "100%", this.height = "100%", this.child});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DivElement(
      styles: {'width': width, 'height': height},
      child: child,
    );
  }
}
