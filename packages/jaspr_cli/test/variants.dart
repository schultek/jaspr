import 'package:jaspr_cli/src/commands/create_command.dart';
import 'package:test/test.dart';

import 'file_matchers.dart';

final variants = [
  for (var mode in RenderingMode.values)
    for (var hydration in HydrationMode.valuesFor(mode))
      for (var routing in RoutingOption.values)
        for (var flutter in FlutterOption.values)
          for (var backend in BackendOption.valuesFor(mode))
            TestVariant(mode: mode, hydration: hydration, routing: routing, flutter: flutter, backend: backend),
];

class TestVariant {
  final RenderingMode mode;
  final HydrationMode hydration;
  final RoutingOption routing;
  final FlutterOption flutter;
  final BackendOption? backend;

  const TestVariant({
    required this.mode,
    required this.hydration,
    required this.routing,
    required this.flutter,
    required this.backend,
  });

  String get name =>
      '${mode.name}${hydration.option} routing:${routing.option} flutter:${flutter.option}${backend != null ? ' backend:${backend!.option}' : ''}';

  String get options =>
      '-m ${mode.name}${hydration.option} -r ${routing.option} -f ${flutter.option}${backend != null ? ' -b ${backend!.option}' : ''}';

  Set<String> get packages => {
        if (routing != RoutingOption.none) 'packages/jaspr_router',
        if (flutter == FlutterOption.embedded) 'pacakges/jaspr_flutter_embed',
        if (flutter != FlutterOption.none) 'modules/build/jaspr_web_compilers',
      };

  Set<(String, Matcher)> get files => {
        ('pubspec.yaml', fileExists),
        ('README.md', fileExists),
        ...mode.files,
        ...routing.files,
        ...flutter.files,
        ...?backend?.files,
      };

  Set<String> get resources => {
        ...mode.resources,
        ...routing.resources,
        ...flutter.resources,
        ...?backend?.resources,
      };

  Set<String> get outputs => {
        ...mode.outputs,
        ...routing.outputs,
        ...flutter.outputs,
        ...?backend?.outputs,
      };
}

extension on RenderingMode {
  Set<(String, Matcher)> get files => switch (this) {
        RenderingMode.static || RenderingMode.server => {
            ('lib/main.dart', fileExists),
            ('lib/styles.dart', fileExists),
          },
        RenderingMode.client => {
            ('web/index.html', fileExists),
            ('web/styles.css', fileExists),
          },
      };
  Set<String> get resources => {};
  Set<String> get outputs => {};
}

enum HydrationMode {
  none(''),
  auto(':auto');

  const HydrationMode(this.option);
  final String option;

  static List<HydrationMode> valuesFor(RenderingMode mode) =>
      switch (mode) { RenderingMode.client => [none], _ => [auto, none] };

  Set<(String, Matcher)> get files => switch (this) {
        none => {
            ('web/main.dart', fileExists),
          },
        auto => {
            ('lib/jaspr_options.dart', fileExists),
          }
      };
  Set<String> get resources => {};
  Set<String> get outputs => {};
}

enum RoutingOption {
  none('none'),
  singlePage('single-page'),
  multiPage('multi-page');

  const RoutingOption(this.option);
  final String option;

  Set<(String, Matcher)> get files => switch (this) {
        singlePage || multiPage => {
            ('lib/components/header.dart', fileExists),
          },
        none => {},
      };
  Set<String> get resources => {};
  Set<String> get outputs => {};
}

enum FlutterOption {
  none('none'),
  embedded('embedded'),
  pluginsOnly('plugins-only');

  const FlutterOption(this.option);
  final String option;

  Set<(String, Matcher)> get files => switch (this) {
        none => {},
        embedded => {
            ('lib/components/flutter_counter.dart', fileExists),
            ('lib/components/flutter_counter_fallback.dart', fileExists),
            ('web/manifest.json', fileExists),
          },
        pluginsOnly => {}
      };
  Set<String> get resources => {};
  Set<String> get outputs => {};
}

enum BackendOption {
  none('none'),
  shelf('shelf'),
  dartFrog('dart_frog');

  const BackendOption(this.option);
  final String option;

  static List<BackendOption?> valuesFor(RenderingMode mode) =>
      switch (mode) { RenderingMode.server => values, _ => [null] };

  Set<(String, Matcher)> get files => {};
  Set<String> get resources => {};
  Set<String> get outputs => {};
}
