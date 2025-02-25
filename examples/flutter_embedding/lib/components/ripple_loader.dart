import 'package:jaspr/jaspr.dart';

class RippleLoader extends StatelessComponent {
  const RippleLoader({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      styles: Styles(
        height: 100.percent,
        display: Display.flex,
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
