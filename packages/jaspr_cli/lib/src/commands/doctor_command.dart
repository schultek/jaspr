import 'dart:io';

import 'package:mason/mason.dart';

import '../analytics.dart';
import '../version.dart';
import 'base_command.dart';

class DoctorCommand extends BaseCommand {
  DoctorCommand({super.logger});

  @override
  String get description => 'Shows information about the environment and project.';

  @override
  String get name => 'doctor';

  @override
  String get category => 'Tooling';

  @override
  Future<int> run() async {
    await super.run();

    var sections = <DoctorSection>[];

    sections.add((
      name: 'Jaspr CLI',
      details: 'Version $jasprCliVersion',
      items: [
        'Dart Version ${Platform.version} at ${Platform.executable}',
        'Running on ${Platform.operatingSystem} ${Platform.operatingSystemVersion} - Locale ${Platform.localeName}',
        'Analytics: ${analyticsEnabled ? 'Enabled' : 'Disabled'}',
      ]
    ));

    String? findDependency(String name, {bool reportMissing = false}) {
      var isDev = false;
      var dep = config!.pubspecYaml['dependencies']?[name];
      if (dep == null) {
        dep = config!.pubspecYaml['dev_dependencies']?[name];
        isDev = true;
      }
      if (dep == null) {
        if (reportMissing) {
          return '\n    • $name: Missing Dependency';
        } else {
          return null;
        }
      } else {
        return '\n    • $name: $dep${isDev ? ' (dev)' : ''}';
      }
    }

    var dependencies = [
      findDependency('jaspr', reportMissing: true),
      findDependency('jaspr_builder'),
      findDependency('jaspr_web_compilers'),
      findDependency('jaspr_test'),
      findDependency('jaspr_flutter_embed'),
      findDependency('jaspr_riverpod'),
      findDependency('jaspr_router'),
      findDependency('jaspr_tailwind'),
    ].whereType<String>();

    sections.add((
      name: 'Current Project',
      details: null,
      items: [
        'Dependencies on core packages:${dependencies.join()}',
        'Rendering mode: ${config!.mode}',
        'Uses jaspr compilers: ${config!.usesJasprWebCompilers}',
        'Uses flutter embedding: ${config!.usesFlutter}',
      ]
    ));

    for (var s in sections) {
      var out = StringBuffer('${green.wrap('[✓]')} ${styleBold.wrap(lightBlue.wrap(s.name))!}');
      if (s.details != null) {
        out.write(' (${s.details})');
      }
      for (var i in s.items) {
        out.write('\n  • $i');
      }
      out.writeln();
      logger.logger.info(out.toString());
    }

    return ExitCode.success.code;
  }
}

typedef DoctorSection = ({String name, String? details, List<String> items});
