import 'package:jaspr/jaspr.dart';

class FutureTester<T> extends StatelessComponent {
  const FutureTester(this.future);

  final Future<T> future;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) sync* {
        if (snapshot.connectionState == ConnectionState.waiting) {
          yield const Text('LOADING');
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            yield Text('DATA: ${snapshot.data}');
          } else if (snapshot.hasError) {
            yield Text('ERROR: ${snapshot.error}');
          }
        }
      },
    );
  }
}

class StreamTester<T> extends StatelessComponent {
  const StreamTester(this.stream);

  final Stream<T> stream;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) sync* {
        if (snapshot.connectionState == ConnectionState.waiting) {
          yield const Text('LOADING');
        } else if (snapshot.connectionState == ConnectionState.done) {
          yield const Text('DONE');
        } else if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            yield Text('DATA: ${snapshot.data}');
          } else if (snapshot.hasError) {
            yield Text('ERROR: ${snapshot.error}');
          }
        }
      },
    );
  }
}
