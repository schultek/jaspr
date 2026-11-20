import 'dart:convert';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/options/client_options_builder.dart';
import 'package:test/test.dart';

import '../test_helper.dart';
import 'sources/client_options.dart';
import 'sources/client_options_other.dart';

void main() {
  group('client options builder', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = await createTestReaderWriter();
    });

    test('generates options', () async {
      await testBuilder(
        ClientOptionsBuilder(BuilderOptions({})),
        clientOptionsSources,
        outputs: clientOptionsOutputs,
        readerWriter: reader,
      );
    });

    test('generates options with alternate entrypoint', () async {
      await testBuilder(
        ClientOptionsBuilder(BuilderOptions({})),
        clientOptionsOtherSources,
        outputs: clientOptionsOtherOutputs,
        readerWriter: reader,
      );
    });

    test('uses distinct debug-only library IDs for clients with the same filename', () async {
      await testBuilder(
        ClientOptionsBuilder(BuilderOptions({})),
        {
          ...clientOptionsOtherSources,
          'site|lib/clients.bundle.json': jsonEncode([
            for (final dir in ['a', 'z'])
              {
                'name': 'Counter',
                'id': ['site', 'lib/$dir/counter.dart'],
                'import': 'package:site/$dir/counter.dart',
                'params': <Object?>[],
              },
          ]),
        },
        outputs: {
          'site|lib/other.client.options.dart': decodedMatches(
            allOf(
              contains("libraryId: kDebugMode ? 'package:site/a/counter.dart' : null"),
              contains("libraryId: kDebugMode ? 'package:site/z/counter.dart' : null"),
            ),
          ),
        },
        readerWriter: reader,
      );
    });

    test('generates reloadable options before the first client is added', () async {
      await testBuilder(
        ClientOptionsBuilder(BuilderOptions({})),
        {...clientOptionsSources, 'site|lib/clients.bundle.json': '[]'},
        outputs: {
          'site|lib/main.client.options.dart': decodedMatches(
            allOf(
              contains(r'ClientOptions(clients: _$clients)'),
              contains(r'Map<String, ClientLoader> _$clients() => {};'),
            ),
          ),
        },
        readerWriter: reader,
      );
    });
  });
}
