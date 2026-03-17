@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';
import 'package:jaspr_test/server_test.dart';

import '../utils.dart';

void main() {
  group('sync', () {
    testServer('writes provider values to output', (tester) async {
      tester.pumpComponent(
        div([
          ProviderScope(
            sync: [
              Provider((_) => 'value').syncWith('some_key'),
              StateProvider((_) => 42).syncWith('some_number'),
            ],
            child: p([Component.text('Hello\nWorld')]),
          ),
        ]),
      );

      final doc = await tester.request('/');
      expect(
        doc.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head></head>\n'
          '  <body>\n'
          '    <div>\n'
          '      <!--\${"some_key":"value","some_number":42}-->\n'
          '      <p>\n'
          '        Hello\n'
          '        World\n'
          '      </p>\n'
          '    </div>\n'
          '  </body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('preloads async provider values then outputs', (tester) async {
      final someFutureProvider = FutureProvider(
        (_) async => Future<void>.delayed(Duration(milliseconds: 100)).then((_) => 'value'),
      );

      dynamic providerValue;

      tester.pumpComponent(
        div([
          ProviderScope(
            sync: [
              someFutureProvider.syncWith('some_key'),
            ],
            child: p([
              Builder(
                builder: (context) {
                  providerValue = context.read(someFutureProvider);
                  return Component.text('Hello\nWorld');
                },
              ),
            ]),
          ),
        ]),
      );

      final doc = await tester.request('/');
      expect(
        doc.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head></head>\n'
          '  <body>\n'
          '    <div>\n'
          '      <!--\${"some_key":"value"}-->\n'
          '      <p>\n'
          '        Hello\n'
          '        World\n'
          '      </p>\n'
          '    </div>\n'
          '  </body>\n'
          '</html>\n'
          '',
        ),
      );

      expect(providerValue, equals(AsyncValue.data('value')));
    });

    testServer('uses codec when encoding sync provider value', (tester) async {
      final p1 = StateProvider((_) => 21);

      tester.pumpComponent(
        div([
          ProviderScope(
            sync: [
              p1.syncWith('some_number', codec: DoublingCodec()),
            ],
            child: p([
              Builder(
                builder: (context) {
                  final v1 = context.read(p1);
                  return Component.text('One: $v1');
                },
              ),
            ]),
          ),
        ]),
      );

      final doc = await tester.request('/');
      expect(
        doc.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html><head></head><body><div><!--\${"some_number":42}--><p>One: 21</p></div></body></html>\n'
          '',
        ),
      );
    });
  });
}
