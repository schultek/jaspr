import 'dart:convert';

const importsSources = {
  'site|lib/target.dart': '''
    import 'package:jaspr/jaspr.dart';
    
    @Import.onWeb('dart:html', show: [#window, #Window])
    @Import.onServer('dart:io', show: [#HttpServer])
    @Import.onServer('dart:collection', show: [#IterableExtensions])
    import 'target.imports.dart';
  ''',
  'site|lib/other.dart': '''
    import 'package:jaspr/jaspr.dart';
    
    @Import.onWeb('dart:html', show: [#window, #Window, #Document])
    @Import.onServer('dart:io', show: [#HttpServer, #HttpHeaders])
    import 'other.imports.dart';
  ''',
};

const conflictingImportsSources = {
  'site|lib/conflict.dart': '''
    import 'package:jaspr/jaspr.dart';
    
    @Import.onWeb('package:jaspr/client.dart', show: [#Document])
    import 'conflict.imports.dart';
  ''',
};

final importsModuleOutput = {
  'site|lib/target.imports.json': jsonEncode([
    {
      'url': 'dart:html',
      'platform': 0,
      'elements': [
        {'name': 'window', 'type': 2, 'details': <String>[]},
        {'name': 'Window', 'type': 0, 'details': <String>[]},
      ],
    },
    {
      'url': 'dart:io',
      'platform': 1,
      'elements': [
        {'name': 'HttpServer', 'type': 0, 'details': <String>[]},
      ],
    },
    {
      'url': 'dart:collection',
      'platform': 1,
      'elements': [
        {
          'name': 'IterableExtensions',
          'type': 1,
          'details': [
            'dynamic get indexed => null;',
            'dynamic get firstOrNull => null;',
            'dynamic get lastOrNull => null;',
            'dynamic get singleOrNull => null;',
            'dynamic get elementAtOrNull => null;',
          ],
        },
      ],
    },
  ]),
  'site|lib/other.imports.json': jsonEncode([
    {
      'url': 'dart:html',
      'platform': 0,
      'elements': [
        {'name': 'window', 'type': 2, 'details': <String>[]},
        {'name': 'Window', 'type': 0, 'details': <String>[]},
        {'name': 'Document', 'type': 0, 'details': <String>[]},
      ],
    },
    {
      'url': 'dart:io',
      'platform': 1,
      'elements': [
        {'name': 'HttpServer', 'type': 0, 'details': <String>[]},
        {'name': 'HttpHeaders', 'type': 0, 'details': <String>[]},
      ],
    },
  ]),
};

final conflictingImportsModuleOutput = {
  'site|lib/conflict.imports.json': jsonEncode([
    {
      'url': 'package:jaspr/client.dart',
      'platform': 0,
      'elements': [
        {'name': 'Document', 'type': 0, 'details': <String>[]},
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
      '    show IterableExtensions, HttpServer, HttpServerOrStubbed;\n'
      '',
  'site|lib/other.imports.dart':
      '// dart format off\n'
      '// ignore_for_file: type=lint\n\n'
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'export \'generated/imports/_web.dart\'\n'
      '    if (dart.library.io) \'generated/imports/_stubs.dart\'\n'
      '    show window, Window, WindowOrStubbed, Document, DocumentOrStubbed;\n'
      '\n'
      'export \'generated/imports/_vm.dart\'\n'
      '    if (dart.library.js_interop) \'generated/imports/_stubs.dart\'\n'
      '    show HttpServer, HttpServerOrStubbed, HttpHeaders, HttpHeadersOrStubbed;\n'
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
      'import \'dart:html\' show Window, Document;\n'
      'export \'dart:html\' show window, Window, Document;\n'
      '\n'
      'typedef DocumentOrStubbed = Document;\n'
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
      'import \'dart:io\' show HttpServer, HttpHeaders;\n'
      'export \'dart:collection\' show IterableExtensions;\n'
      'export \'dart:io\' show HttpServer, HttpHeaders;\n'
      '\n'
      'typedef HttpHeadersOrStubbed = HttpHeaders;\n'
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
      'extension IterableExtensions on dynamic {\n'
      '  dynamic get indexed => null;\n'
      '  dynamic get firstOrNull => null;\n'
      '  dynamic get lastOrNull => null;\n'
      '  dynamic get singleOrNull => null;\n'
      '  dynamic get elementAtOrNull => null;\n'
      '}\n'
      '\n'
      'dynamic window;\n'
      'dynamic Window;\n'
      'typedef WindowOrStubbed = dynamic;\n'
      'dynamic Document;\n'
      'typedef DocumentOrStubbed = dynamic;\n'
      'dynamic HttpServer;\n'
      'typedef HttpServerOrStubbed = dynamic;\n'
      'dynamic HttpHeaders;\n'
      'typedef HttpHeadersOrStubbed = dynamic;\n'
      '',
};
