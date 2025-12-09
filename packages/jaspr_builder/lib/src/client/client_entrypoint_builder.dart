import 'dart:async';

import 'package:build/build.dart';

import '../utils.dart';

/// Builds the entrypoint for client components.
class ClientEntrypointBuilder implements Builder {
  ClientEntrypointBuilder(this.options);

  final BuilderOptions options;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      final source = await generateEntrypoint(buildStep);
      if (source != null) {
        final outputId = AssetId(buildStep.inputId.package, buildStep.inputId.path.replaceFirst('lib/', 'web/'));
        await buildStep.writeAsFormattedDart(outputId, source);
      }
    } catch (e, st) {
      print(
        'An unexpected error occurred.\n'
        'This is probably a bug in jaspr_builder.\n'
        'Please report this here: '
        'https://github.com/schultek/jaspr/issues\n\n'
        'The error was:\n$e\n\n$st',
      );
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    'lib/{{file}}.client.dart': ['web/{{file}}.client.dart'],
  };

  Future<String?> generateEntrypoint(BuildStep buildStep) async {
    var source =
        '''
      import 'package:jaspr/client.dart';
      [[/]]
      
      void main() {
        [[${buildStep.inputId.toImportUrl()}]].main();
      }
    ''';

    source = ImportsWriter().resolve(source);
    return source;
  }
}
