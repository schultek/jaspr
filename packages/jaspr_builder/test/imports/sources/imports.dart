import 'dart:convert';

const importsSources = {
  'site|lib/target.dart': '''
    import 'package:jaspr/jaspr.dart';
    
    @Import.onWeb('dart:html', show: [#window, #Window])
    @Import.onServer('dart:io', show: [#HttpServer])
    @Import.onServer('dart:collection', show: [#IterableExtensions])
    import 'target.imports.dart';
  ''',
};

final importsModuleOutput = {
  'site|lib/target.imports.json': jsonEncode([
    {
      "url": "dart:html",
      "platform": 0,
      "elements": [
        {"name": "window", "type": 2, "details": <String>[]},
        {"name": "Window", "type": 0, "details": <String>[]},
      ],
    },
    {
      "url": "dart:io",
      "platform": 1,
      "elements": [
        {"name": "HttpServer", "type": 0, "details": <String>[]},
      ],
    },
    {
      "url": "dart:collection",
      "platform": 1,
      "elements": [
        {
          "name": "IterableExtensions",
          "type": 1,
          "details": [
            "dynamic get indexed => null;",
            "dynamic get firstOrNull => null;",
            "dynamic get lastOrNull => null;",
            "dynamic get singleOrNull => null;",
            "dynamic get elementAtOrNull => null;",
          ],
        },
      ],
    },
  ]),
};

final importsOutput = {
  'site|lib/target.imports.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'export \'generated/imports/_web.dart\'\n'
      '    if (dart.library.io) \'generated/imports/_stubs.dart\'\n'
      '    show window, Window, WindowOrStubbed;\n'
      '\n'
      'export \'generated/imports/_vm.dart\'\n'
      '    if (dart.library.js_interop) \'generated/imports/_stubs.dart\'\n'
      '    show HttpServer, HttpServerOrStubbed, IterableExtensions;\n'
      '',
};

final importsStubsOutput = {
  'site|lib/generated/imports/_web.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      '// ignore_for_file: directives_ordering, deprecated_member_use\n'
      '\n'
      'import \'dart:html\' show Window;\n'
      'export \'dart:html\' show window, Window;\n'
      '\n'
      'typedef WindowOrStubbed = Window;\n'
      '',
  'site|lib/generated/imports/_vm.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n'
      '\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      '// ignore_for_file: directives_ordering, deprecated_member_use\n'
      '\n'
      'import \'dart:io\' show HttpServer;\n'
      'export \'dart:io\' show HttpServer;\n'
      'export \'dart:collection\' show IterableExtensions;\n'
      '\n'
      'typedef HttpServerOrStubbed = HttpServer;\n'
      '',
  'site|lib/generated/imports/_stubs.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      '// ignore_for_file: directives_ordering, non_constant_identifier_names\n'
      '\n'
      'dynamic window;\n'
      'dynamic Window;\n'
      'typedef WindowOrStubbed = dynamic;\n'
      'dynamic HttpServer;\n'
      'typedef HttpServerOrStubbed = dynamic;\n'
      '\n'
      'extension IterableExtensions on dynamic {\n'
      '  dynamic get indexed => null;\n'
      '  dynamic get firstOrNull => null;\n'
      '  dynamic get lastOrNull => null;\n'
      '  dynamic get singleOrNull => null;\n'
      '  dynamic get elementAtOrNull => null;\n'
      '}\n'
      '',
};
