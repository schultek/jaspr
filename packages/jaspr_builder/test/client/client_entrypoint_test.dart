import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jaspr_builder/src/client/client_entrypoint_builder.dart';
import 'package:test/test.dart';

void main() {
  group('client entrypoint', () {
    late TestReaderWriter reader;

    setUp(() async {
      reader = TestReaderWriter(rootPackage: 'site');
      await reader.testing.loadIsolateSources();
    });

    test('generates main entrypoint in web directory', () async {
      await testBuilder(
        ClientEntrypointBuilder(BuilderOptions({})),
        {
          'site|lib/main.client.dart': '''
              import 'package:jaspr/client.dart';
              
              void main() {
                runApp(div([]));
              }
            ''',
        },
        outputs: {
          'site|web/main.client.dart':
              ''
              '// dart format off\n'
              '// ignore_for_file: type=lint\n'
              '\n'
              '// GENERATED FILE, DO NOT MODIFY\n'
              '// Generated with jaspr_builder\n'
              '\n'
              'import \'package:jaspr/client.dart\';\n'
              'import \'package:site/main.client.dart\' as _main\$client;\n'
              '\n'
              'void main() {\n'
              '  _main\$client.main();\n'
              '}\n'
              '',
        },
        readerWriter: reader,
      );
    });

    test('generates other entrypoint in web directory', () async {
      await testBuilder(
        ClientEntrypointBuilder(BuilderOptions({})),
        {
          'site|lib/subdir/other.client.dart': '''
              import 'package:jaspr/client.dart';
              
              void main() {
                runApp(div([]));
              }
            ''',
        },
        outputs: {
          'site|web/subdir/other.client.dart':
              ''
              '// dart format off\n'
              '// ignore_for_file: type=lint\n'
              '\n'
              '// GENERATED FILE, DO NOT MODIFY\n'
              '// Generated with jaspr_builder\n'
              '\n'
              'import \'package:jaspr/client.dart\';\n'
              'import \'package:site/subdir/other.client.dart\' as _other\$client;\n'
              '\n'
              'void main() {\n'
              '  _other\$client.main();\n'
              '}\n'
              '',
        },
        readerWriter: reader,
      );
    });
  });
}
