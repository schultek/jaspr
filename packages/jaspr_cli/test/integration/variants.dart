import 'package:jaspr_cli/src/commands/create_command.dart';
import 'package:test/test.dart';

import 'file_matchers.dart';

final allVariants = [
  for (var mode in RenderingMode.values)
    for (var routing in RoutingOption.values)
      for (var flutter in FlutterOption.values)
        for (var backend in BackendOption.valuesFor(mode))
          TestVariant(mode: mode, routing: routing, flutter: flutter, backend: backend),
];

class TestVariant {
  final RenderingMode mode;
  final RoutingOption routing;
  final FlutterOption flutter;
  final BackendOption backend;

  const TestVariant({
    required this.mode,
    required this.routing,
    required this.flutter,
    required this.backend,
  });

  String get name => '${mode.name} routing:${routing.option} flutter:${flutter.option} backend:${backend.option}';

  String get options => '-m ${mode.name} -r ${routing.option} -f ${flutter.option} -b ${backend.option}';

  String get tag => '${mode.tag}${routing.tag}${flutter.tag}${backend.tag}';

  Set<String> get packages => {
    if (routing != RoutingOption.none) 'packages/jaspr_router',
    if (flutter == FlutterOption.embedded) 'packages/jaspr_flutter_embed',
  };

  Set<(String, Matcher)> get files => {
    ('pubspec.yaml', fileExists),
    ('README.md', fileExists),
    ...mode.files,
    ...routing.files,
    ...flutter.files,
    ...backend.files,
  };

  Set<String> get resources => {
    '/',
    ...mode.resources,
    ...routing.resources,
    ...flutter.resources,
    ...backend.resources,
  };

  Set<(String, Matcher)> get outputs => {
    ...mode.outputs,
    ...routing.outputs,
    ...flutter.outputs,
    ...backend.outputs,
    if (mode == RenderingMode.static && routing != RoutingOption.none) ('about/index.html', fileExists),
  };
}

extension on RenderingMode {
  String get tag => switch (this) {
    RenderingMode.static => 's',
    RenderingMode.server => 'v',
    RenderingMode.client => 'c',
  };

  Set<(String, Matcher)> get files => switch (this) {
    RenderingMode.static || RenderingMode.server => {
      ('lib/main.client.dart', fileExists),
      ('lib/main.server.dart', fileExists),
      ('lib/main.client.options.dart', fileExists),
      ('lib/main.server.options.dart', fileExists),
    },
    RenderingMode.client => {
      ('lib/main.client.dart', fileExists),
      ('lib/main.client.options.dart', isNot(fileExists)),
      ('web/index.html', fileExists),
      ('web/styles.css', fileExists),
    },
  };
  Set<String> get resources => {};
  Set<(String, Matcher)> get outputs => {
    ('main.client.dart.js', fileExists),
  };
}

enum RoutingOption {
  none('none'),
  singlePage('single-page'),
  multiPage('multi-page');

  const RoutingOption(this.option);
  final String option;

  String get tag => switch (this) {
    none => 'n',
    singlePage => 's',
    multiPage => 'm',
  };

  Set<(String, Matcher)> get files => switch (this) {
    singlePage || multiPage => {
      ('lib/components/header.dart', fileExists),
    },
    none => {},
  };
  Set<String> get resources => switch (this) {
    singlePage || multiPage => {'/about'},
    none => {},
  };
  Set<(String, Matcher)> get outputs => {};
}

enum FlutterOption {
  none('none'),
  embedded('embedded'),
  pluginsOnly('plugins-only');

  const FlutterOption(this.option);
  final String option;

  String get tag => switch (this) {
    none => 'n',
    embedded => 'e',
    pluginsOnly => 'p',
  };

  Set<(String, Matcher)> get files => switch (this) {
    none => {},
    embedded => {
      ('lib/components/embedded_counter.dart', fileExists),
      ('lib/components/embedded_counter.imports.dart', fileExists),
      ('lib/widgets/counter.dart', fileExists),
      ('web/manifest.json', fileExists),
      ('web/flutter_bootstrap.js', fileExists),
    },
    pluginsOnly => {},
  };
  Set<String> get resources => {};
  Set<(String, Matcher)> get outputs => switch (this) {
    none => {},
    embedded => {
      ('manifest.json', fileExists),
      ('version.json', fileExists),
      ('flutter_service_worker.js', fileExists),
      ('canvaskit/canvaskit.js', fileExists),
    },
    pluginsOnly => {},
  };
}

enum BackendOption {
  none('none'),
  shelf('shelf');

  const BackendOption(this.option);
  final String option;

  static List<BackendOption> valuesFor(RenderingMode mode) => switch (mode) {
    RenderingMode.server => values,
    _ => [none],
  };

  String get tag => switch (this) {
    none => 'n',
    shelf => 's',
  };

  Set<(String, Matcher)> get files => {};
  Set<String> get resources => {};
  Set<(String, Matcher)> get outputs => {};
}
