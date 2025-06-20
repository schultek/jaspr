import 'package:jaspr/jaspr.dart';

class RippleLoader extends StatelessComponent {
  const RippleLoader({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      styles: Styles(
        display: Display.flex,
        height: 100.percent,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
        backgroundColor: Colors.black,
      ),
      [
        div(classes: 'lds-ripple', [div([]), div([])])
      ],
    );
  }
}
