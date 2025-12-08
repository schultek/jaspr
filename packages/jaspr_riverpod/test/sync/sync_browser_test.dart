@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:web/web.dart';

void main() {
  group('sync', () {
    testClient('overrides sync provider with value', (tester) {
      document.body!.innerHTML =
          '<div>\n'
                  '  <!--\${"some_key":"value","some_number":42}-->\n'
                  '  <p>Hello World</p>\n'
                  '</div>\n'
              .toJS;

      final p1 = Provider((_) => 'initial');
      final p2 = StateProvider((_) => 0);

      tester.pumpComponent(
        div([
          ProviderScope(
            sync: [
              p1.syncWith('some_key'),
              p2.syncWith('some_number'),
            ],
            child: p([
              Builder(
                builder: (context) {
                  final v1 = context.read(p1);
                  final v2 = context.watch(p2);

                  return Component.text('One: $v1, Two: $v2');
                },
              ),
            ]),
          ),
        ]),
      );

      expect(find.text('One: value, Two: 42'), findsOneComponent);
    });
  });
}
