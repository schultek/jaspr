import 'dart:convert';

const importsSources = {
  'site|lib/target.dart': '''
    import 'package:jaspr/jaspr.dart';
    
    @Import.onWeb('dart:html', show: [#window, #Window])
    @Import.onServer('dart:io', show: [#HttpServer])
    import 'target.imports.dart';
  ''',
};

final importsModuleOutput = {
  'site|lib/target.imports.json': jsonEncode([
    {
      "url": "dart:html",
      "show": ["window", "Window"],
      "platform": 0
    },
    {
      "url": "dart:io",
      "show": ["HttpServer"],
      "platform": 1
    }
  ]),
};

final importsOutput = {
  'site|lib/target.imports.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      'export \'generated/imports/_web.dart\' if (dart.library.io) \'generated/imports/_stubs.dart\'\n'
      '    show window, Window, WindowOrStubbed;\n'
      '\n'
      'export \'generated/imports/_vm.dart\' if (dart.library.js_interop) \'generated/imports/_stubs.dart\'\n'
      '    show HttpServer, HttpServerOrStubbed;\n'
      ''
};

final importsStubsOutput = {
  'site|lib/generated/imports/_web.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      '// ignore_for_file: directives_ordering\n'
      '\n'
      'import \'dart:html\' show Window;\n'
      'export \'dart:html\' show window, Window;\n'
      '\n'
      'typedef WindowOrStubbed = Window;\n'
      '',
  'site|lib/generated/imports/_vm.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      '// ignore_for_file: directives_ordering\n'
      '\n'
      'import \'dart:io\' show HttpServer;\n'
      'export \'dart:io\' show HttpServer;\n'
      '\n'
      'typedef HttpServerOrStubbed = HttpServer;\n'
      '',
  'site|lib/generated/imports/_stubs.dart': '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n'
      '\n'
      '// ignore_for_file: directives_ordering, non_constant_identifier_names\n'
      '\n'
      'dynamic window;\n'
      'dynamic Window;\n'
      'typedef WindowOrStubbed = dynamic;\n'
      'dynamic HttpServer;\n'
      'typedef HttpServerOrStubbed = dynamic;\n'
      '',
};
