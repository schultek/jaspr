import 'dart:convert';
import 'dart:io';

import 'package:io/io.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../dev/util.dart';
import '../logging.dart';
import 'base_command.dart';

const _agents = {
  'antigravity': '.agents',
  'cursor': '.cursor',
  'claude-code': '.claude-code',
  'cline': '.cline',
  'codex': '.agents',
  'copilot': '.github',
  'command-code': '.commandcode',
  'opencode': '.opencode',
  'continue': '.continue',
  'windsurf': '.windsurf',
  'general': '.agents',
};

class InstallSkillsCommand extends BaseCommand {
  InstallSkillsCommand({super.logger}) {
    argParser.addOption(
      'agent',
      abbr: 'a',
      help: 'The agent to install skills for.',
      allowed: _agents.keys,
    );
  }

  @override
  String get description => 'Installs Jaspr skills to your workspace.';

  @override
  String get name => 'install-skills';

  @override
  String get category => 'Tooling';

  @override
  Future<int> runCommand() async {
    final packageConfigPath = findPackageConfigFilePath();
    if (packageConfigPath == null) {
      logger.write(
        'Could not find package_config.json. Make sure to run "dart pub get" first.',
        level: Level.error,
      );
      return 1;
    }

    final packageConfigFile = File(packageConfigPath);
    final config = jsonDecode(packageConfigFile.readAsStringSync());
    String? jasprPackageUri;
    if (config case {'packages': final List<Object?> configPackages}) {
      final jasprEntry = configPackages
          .whereType<Map<String, dynamic>>()
          .where((p) => p['name'] == 'jaspr')
          .firstOrNull;
      if (jasprEntry != null) {
        jasprPackageUri = jasprEntry['rootUri'] as String?;
      }
    }

    if (jasprPackageUri == null) {
      logger.write('Could not find "jaspr" package in package_config.json.', level: Level.error);
      return 1;
    }

    final jasprPath = p.isAbsolute(jasprPackageUri)
        ? p.fromUri(jasprPackageUri)
        : p.join(p.dirname(packageConfigFile.absolute.path), jasprPackageUri);
    final skillsSourceDir = Directory(p.join(jasprPath, 'skills'));

    if (!skillsSourceDir.existsSync()) {
      logger.write(
        'Could not find skills directory in jaspr package at ${skillsSourceDir.path}.',
        level: Level.critical,
      );
      return 1;
    }

    String? targetDirName;

    final requestedAgent = argResults?['agent'] as String?;
    if (requestedAgent != null) {
      targetDirName = _agents[requestedAgent];
    } else {
      for (final entry in _agents.entries) {
        if (Directory(p.join(entry.value, 'skills')).existsSync()) {
          targetDirName = entry.value;
          logger.write('Using auto-detected skills directory: $targetDirName/skills');
          break;
        }
      }
    }

    if (targetDirName == null) {
      logger.write(
        'Could not auto-detect an agent directory. Please specify an agent using --agent.',
      );
      return 1;
    }

    final skills = skillsSourceDir.listSync().whereType<Directory>().toList();
    final targetBaseDir = Directory(p.join(targetDirName, 'skills'));
    if (!targetBaseDir.existsSync()) {
      targetBaseDir.createSync(recursive: true);
    }

    bool didUpdateSkills = false;

    for (final skillDir in skills) {
      final skillName = p.basename(skillDir.path);
      final targetSkillDir = Directory(p.join(targetBaseDir.path, skillName));
      final skillFile = File(p.join(skillDir.path, 'SKILL.md'));

      if (!skillFile.existsSync()) continue;

      final sourceVersion = _getSkillVersion(skillFile);

      final targetSkillFile = File(p.join(targetSkillDir.path, 'SKILL.md'));

      if (targetSkillFile.existsSync()) {
        final targetVersion = _getSkillVersion(targetSkillFile);
        if (sourceVersion == targetVersion) {
          continue;
        }
        logger.write('Updating skill $skillName to version $sourceVersion...');
      } else {
        logger.write('Adding skill $skillName for version $sourceVersion...');
      }

      if (targetSkillDir.existsSync()) {
        targetSkillDir.deleteSync(recursive: true);
      }
      copyPathSync(skillDir.path, targetSkillDir.path);

      didUpdateSkills = true;
    }

    if (!didUpdateSkills) {
      logger.write('All skills are already installed and up to date.');
    }

    return 0;
  }

  String? _getSkillVersion(File skillFile) {
    try {
      final content = skillFile.readAsStringSync();
      final firstMatch = RegExp(r'^---(.*?)---', dotAll: true).firstMatch(content);
      if (firstMatch != null) {
        final yaml = loadYaml(firstMatch.group(1)!);
        if (yaml case {'metadata': {'jaspr_version': final String version}}) {
          return version;
        }
      }
    } catch (_) {}
    return null;
  }
}
