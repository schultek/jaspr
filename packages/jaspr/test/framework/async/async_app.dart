import 'package:jaspr/jaspr.dart';

class FutureTester<T> extends StatelessComponent {
  FutureTester(this.future);

  final Future<T> future;

  @override
  Component build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('LOADING');
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Text('DATA: ${snapshot.data}');
          } else if (snapshot.hasError) {
            return Text('ERROR: ${snapshot.error}');
          }
        }
        return Text('UNKNOWN STATE: ${snapshot.connectionState}');
      },
    );
  }
}

class StreamTester<T> extends StatelessComponent {
  StreamTester(this.stream);

  final Stream<T> stream;

  @override
  Component build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('LOADING');
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Text('DONE');
        } else if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return Text('DATA: ${snapshot.data}');
          } else if (snapshot.hasError) {
            return Text('ERROR: ${snapshot.error}');
          }
        }
        return Text('UNKNOWN STATE: ${snapshot.connectionState}');
      },
    );
  }
}
