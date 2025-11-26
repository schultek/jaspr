@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';

class App1 extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div([], attributes: {'data-app': '1'});
  }
}

class App2 extends StatelessComponent {
  const App2({this.count, this.label});

  final int? count;
  final String? label;

  @override
  Component build(BuildContext context) {
    return div([], attributes: {'data-app': '2'});
  }
}

class App3 extends StatefulComponent {
  const App3();

  @override
  State<App3> createState() => _App3State();
}

class _App3State extends State<App3> with SyncStateMixin {
  int count = 3;

  @override
  getState() {
    return {'count': count};
  }

  @override
  void updateState(value) {
    count = value['count'];
  }

  @override
  Component build(BuildContext context) {
    return div([], attributes: {'data-app': '3'});
  }
}

class App4 extends StatefulComponent {
  const App4();

  @override
  State<App4> createState() => _App4State();
}

class _App4State extends State<App4> with SyncStateMixin, PreloadStateMixin {
  String label = 'hello';

  @override
  Future<void> preloadState() async {
    await Future.delayed(Duration(milliseconds: 10));
    label = 'world';
  }

  @override
  getState() {
    return {'label': label};
  }

  @override
  void updateState(value) {
    label = value['label'];
  }

  @override
  Component build(BuildContext context) {
    return div([], attributes: {'data-app': '4'});
  }
}

void main() {
  group('@client', () {
    setUpAll(() {
      Jaspr.initializeApp(
        options: JasprOptions(
          clients: {
            App1: ClientTarget<App1>('app1'),
            App2: ClientTarget<App2>('app2', params: (app) => {'count': app.count, 'label': app.label}),
            App3: ClientTarget<App3>('app3'),
            App4: ClientTarget<App4>('app4'),
          },
        ),
      );
    });

    testServer('adds component markers and script', (tester) async {
      tester.pumpComponent(App1());

      var response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body><!--@app1--><div data-app="1"></div><!--/@app1--></body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('adds parameters as data', (tester) async {
      tester.pumpComponent(App2(count: 1, label: 'Test'));

      var response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body><!--@app2 data={"count":1,"label":"Test"}--><div data-app="2"></div><!--/@app2--></body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('adds sync marker inside of component marker', (tester) async {
      tester.pumpComponent(App3());

      var response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body><!--@app3--><!--\${"count":3}--><div data-app="3"></div><!--/@app3--></body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('adds sync marker inside of component marker with preload state', (tester) async {
      tester.pumpComponent(App4());

      var response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body><!--@app4--><!--\${"label":"world"}--><div data-app="4"></div><!--/@app4--></body>\n'
          '</html>\n'
          '',
        ),
      );
    });
  });
}
