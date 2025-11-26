import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class RippleLoader extends StatelessComponent {
  const RippleLoader({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(
        display: .flex,
        height: 100.percent,
        justifyContent: .center,
        alignItems: .center,
        backgroundColor: Colors.black,
      ),
      [
        div(classes: 'lds-ripple', [div([]), div([])]),
      ],
    );
  }
}
