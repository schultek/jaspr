import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World'),
    );

    yield CounterBuilder(builder: (context, count, button) sync* {
      if (count > 5) {
        yield button;
      }

      yield Text('Count is $count', key: ValueKey('text'));

      if (count > 5) {
        yield Text('YAAAY');
      } else {
        yield button;
      }

      if (count > 6) {
        yield Text('Ended');
      }
    });

    yield DomComponent(tag: 'br');

    yield CounterBuilder(builder: (context, count, button) sync* {
      yield button;
      yield DomComponent(tag: 'br');
      if (count < 2) {
        yield CounterBuilder(
          key: GlobalObjectKey('test'),
          builder: (context, count, button) sync* {
            yield Text(count.toString());
            yield button;
          },
        );
      } else if (count < 5) {
        yield DomComponent(
          tag: 'div',
          styles: {'background': 'red'},
          child: CounterBuilder(
            key: GlobalObjectKey('test'),
            builder: (context, count, button) sync* {
              yield Text(count.toString());
              yield button;
            },
          ),
        );
      }
    });
  }
}

typedef CounterChildBuilder = Iterable<Component> Function(BuildContext, int, Component);

class CounterBuilder extends StatefulComponent {
  final int initialValue;
  final CounterChildBuilder builder;

  const CounterBuilder({this.initialValue = 0, required this.builder, Key? key}) : super(key: key);

  @override
  State<CounterBuilder> createState() => _CounterBuilderState();
}

class _CounterBuilderState extends State<CounterBuilder> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    count = component.initialValue;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield* component.builder(
      context,
      count,
      DomComponent(
        key: ValueKey('button'),
        tag: 'button',
        events: {
          'click': (e) {
            setState(() => count++);
          },
        },
        child: Text('Press Me ($count)'),
      ),
    );
  }
}
