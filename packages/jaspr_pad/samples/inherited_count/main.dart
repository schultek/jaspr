// [sample=1] Inherited Counter
import 'package:jaspr/jaspr.dart';

void main() {
  runApp(App());
}

class InheritedCount extends InheritedComponent {
  InheritedCount(this.count, {required Component child}) : super(child: child);

  final int count;

  @override
  bool updateShouldNotify(covariant InheritedCount oldComponent) {
    return count != oldComponent.count;
  }
}

class App extends StatefulComponent {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield InheritedCount(
      count,
      child: CountLabel(),
    );

    yield DomComponent(
      tag: 'button',
      events: {
        'click': (e) {
          setState(() => count++);
        },
      },
      child: Text('Press Me'),
    );
  }
}

class CountLabel extends StatelessComponent {
  const CountLabel({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var count = context.dependOnInheritedComponentOfExactType<InheritedCount>()!.count;
    yield Text('Count is $count');
  }
}
