import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'main.server.options.dart';

import 'counter.dart';
import 'minicounter.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    Document(
      title: 'server_components',
      body: Builder(
        builder: (context) {
          var time = DateTime.now();
          return div(classes: 'server', [
            p([.text('Server Time: $time')]),
            Counter(
              step: time.second,
              child: p(classes: 'server', [
                .text('This is a server component, rendered at $time.'),
                MiniCounter(),
              ]),
            ),
          ]);
        },
      ),
    ),
  );
}

@css
List<StyleRule> get styles => [
  css('.server').styles(
    padding: Padding.all(2.px),
    border: Border.all(color: Colors.red),
  ),
  css('.client').styles(
    padding: Padding.all(2.px),
    border: Border.all(color: Colors.green),
  ),
];
