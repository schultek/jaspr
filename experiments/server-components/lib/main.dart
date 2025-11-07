import 'package:jaspr/server.dart';
import 'jaspr_options.dart';

import 'counter.dart';
import 'minicounter.dart';

void main() {
  Jaspr.initializeApp(options: defaultJasprOptions);

  runApp(
    Document(
      title: 'server_components',
      body: Builder(
        builder: (context) {
          var time = DateTime.now();
          return div(classes: 'server', [
            p([text('Server Time: $time')]),
            Counter(
              step: time.second,
              child: p(classes: 'server', [
                text(
                  'This is a server component asdasdaasdasd, rendered at $time.',
                ),
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
        border: Border(color: Colors.red),
      ),
      css('.client').styles(
        padding: Padding.all(2.px),
        border: Border(color: Colors.green),
      ),
    ];
