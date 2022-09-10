import 'package:jaspr/jaspr.dart';

// A simple island component
// - must be annotated with @island
// - will be bundled into javascript
// - will be hydrated on the client
@island
class Content extends StatelessComponent {

  // Island components can have additional parameters
  // - which must be json-serializable
  // - and will be inserted during hydration
  const Content({required this.greet, super.key});

  final String greet;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    // renders a single <p> element
    yield DomComponent(
      tag: 'p',
      events: {
        'click': (_) {
          print("Clicked on 'Hello $greet'");
        }
      },
      child: Text('Hello $greet'),
    );
  }
}