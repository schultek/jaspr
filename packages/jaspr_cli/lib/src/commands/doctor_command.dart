import 'dart:io';

import 'package:mason/mason.dart';

import '../helpers/analytics.dart';
import '../version.dart';
import 'base_command.dart';

class DoctorCommand extends BaseCommand {
  DoctorCommand({super.logger});

  @override
  String get description => 'Show information about the environment and project.';

  @override
  String get name => 'doctor';

  @override
  String get category => 'Tooling';

  @override
  Future<int> runCommand() async {
    final sections = <DoctorSection>[];

    sections.add((
      name: 'Jaspr CLI',
      details: 'Version $jasprCliVersion',
      items: [
        'Dart Version ${Platform.version} at ${Platform.executable}',
        'Running on ${Platform.operatingSystem} ${Platform.operatingSystemVersion} - Locale ${Platform.localeName}',
        'Analytics: ${analyticsEnabled ? 'Enabled' : 'Disabled'}',
      ],
    ));

    if (project.pubspecYaml != null) {
      String? findDependency(String name, {bool reportMissing = false}) {
        var isDev = false;
        final dependencies = project.requirePubspecYaml['dependencies'] as Map<Object?, Object?>?;
        var dep = dependencies?[name];
        if (dep == null) {
          final devDependencies = project.requirePubspecYaml['dev_dependencies'] as Map<Object?, Object?>?;
          dep = devDependencies?[name];
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

      final dependencies = [
        findDependency('jaspr', reportMissing: true),
        findDependency('jaspr_builder'),
        findDependency('jaspr_content'),
        findDependency('jaspr_test'),
        findDependency('jaspr_flutter_embed'),
        findDependency('jaspr_riverpod'),
        findDependency('jaspr_router'),
      ].whereType<String>();

      sections.add((
        name: 'Current Project',
        details: null,
        items: [
          'Dependencies on core packages:${dependencies.join()}',
          'Rendering mode: ${project.modeOrNull?.name}',
          'Uses flutter embedding: ${project.usesFlutter}',
        ],
      ));
    }

    for (final s in sections) {
      final out = StringBuffer('${green.wrap('[✓]')} ${styleBold.wrap(lightBlue.wrap(s.name))!}');
      if (s.details != null) {
        out.write(' (${s.details})');
      }
      for (final i in s.items) {
        out.write('\n  • $i');
      }
      out.writeln();
      stdout.write(out.toString());
    }

    return 0;
  }
}

typedef DoctorSection = ({String name, String? details, List<String> items});
