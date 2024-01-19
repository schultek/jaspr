import 'package:jaspr/jaspr.dart';

class RippleLoader extends StatelessComponent {
  const RippleLoader({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      styles: Styles.combine([
        Styles.box(height: 100.percent),
        Styles.flexbox(justifyContent: JustifyContent.center, alignItems: AlignItems.center),
        Styles.background(color: Colors.black),
      ]),
      [
        div(classes: 'lds-ripple', [div([]), div([])])
      ],
    );
  }
}
