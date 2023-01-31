import 'package:jaspr/jaspr.dart';

part 'content.g.dart';

// A simple island component
// - must be annotated with @island
// - use the generated '_$<ClassName>' mixin
// - will be bundled into javascript
// - will be hydrated on the client
@island
class Content extends StatelessComponent with _$Content {
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
