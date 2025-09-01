// [sample=1] Inherited Counter
import 'package:jaspr/jaspr.dart';

void main() {
  runApp(App());
}

class InheritedCount extends InheritedComponent {
  InheritedCount(this.count, {required super.child});

  final int count;

  @override
  bool updateShouldNotify(covariant InheritedCount oldComponent) {
    return count != oldComponent.count;
  }
}

class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int count = 0;

  @override
  Component build(BuildContext context) {
    return div([
      InheritedCount(
        count,
        child: CountLabel(),
      ),
      button(
        onClick: () {
          setState(() => count++);
        },
        [text('Press Me')],
      ),
    ]);
  }
}

class CountLabel extends StatelessComponent {
  const CountLabel({super.key});

  @override
  Component build(BuildContext context) {
    var count = context.dependOnInheritedComponentOfExactType<InheritedCount>()!.count;
    return text('Count is $count');
  }
}
