import 'dart:io';

class Section {
  final int priority;
  final String title;
  final String prefix;
  final String impact;
  final String description;

  Section({
    required this.priority,
    required this.title,
    required this.prefix,
    required this.impact,
    required this.description,
  });
}

class Rule {
  final String filename;
  final String id;
  final String title;
  final String impact;
  final String? impactDescription;
  final List<String> tags;
  final String body;

  Rule({
    required this.filename,
    required this.id,
    required this.title,
    required this.impact,
    this.impactDescription,
    required this.tags,
    required this.body,
  });
}

void main() {
  final repoRoot = _findRepoRoot();
  final skillsDir = Directory('${repoRoot.path}/packages/jaspr/skills/jaspr-best-practices');
  final rulesDir = Directory('${skillsDir.path}/rules');

  if (!rulesDir.existsSync()) {
    print('Error: rules directory not found at ${rulesDir.path}');
    exit(1);
  }

  // 1. Parse sections
  final sectionsFile = File('${rulesDir.path}/_sections.md');
  if (!sectionsFile.existsSync()) {
    print('Error: _sections.md not found');
    exit(1);
  }

  final sections = _parseSections(sectionsFile.readAsStringSync());

  // 2. Parse rules
  final rules = <Rule>[];
  for (final entity in rulesDir.listSync()) {
    if (entity is File && entity.path.endsWith('.md') && !entity.path.endsWith('_sections.md')) {
      final rule = _parseRule(entity);
      if (rule != null) {
        rules.add(rule);
      }
    }
  }

  // Sort rules by section priority, then by id
  rules.sort((a, b) {
    final aSection = sections.firstWhere((s) => a.id.startsWith('${s.prefix}-'), orElse: () => _fallbackSection);
    final bSection = sections.firstWhere((s) => b.id.startsWith('${s.prefix}-'), orElse: () => _fallbackSection);
    final prioCmp = aSection.priority.compareTo(bSection.priority);
    if (prioCmp != 0) return prioCmp;
    return a.id.compareTo(b.id);
  });

  print('Loaded ${rules.length} rules across ${sections.length} sections.');

  // 3. Generate AGENTS.md
  final agentsContent = _generateAgentsMd(sections, rules);
  final agentsFile = File('${skillsDir.path}/AGENTS.md');
  agentsFile.writeAsStringSync(agentsContent);
  print('Updated ${agentsFile.path}');

  // 4. Generate SKILL.md
  final skillContent = _generateSkillMd(sections, rules);
  final skillFile = File('${skillsDir.path}/SKILL.md');
  skillFile.writeAsStringSync(skillContent);
  print('Updated ${skillFile.path}');

  print('Done!');
}

final _fallbackSection = Section(
  priority: 99,
  title: 'Other',
  prefix: 'other',
  impact: 'LOW',
  description: '',
);

Directory _findRepoRoot() {
  var dir = Directory.current;
  while (dir.path != dir.parent.path) {
    if (File('${dir.path}/packages/jaspr/pubspec.yaml').existsSync()) {
      return dir;
    }
    dir = dir.parent;
  }
  return Directory.current;
}

List<Section> _parseSections(String content) {
  final sections = <Section>[];
  final lines = content.split('\n');

  int? currentPriority;
  String? currentTitle;
  String? currentPrefix;
  String? currentImpact;
  String? currentDescription;

  void pushCurrent() {
    final priority = currentPriority;
    final title = currentTitle;
    final prefix = currentPrefix;
    if (priority != null && title != null && prefix != null) {
      sections.add(
        Section(
          priority: priority,
          title: title,
          prefix: prefix,
          impact: currentImpact ?? 'MEDIUM',
          description: currentDescription ?? '',
        ),
      );
    }
  }

  for (var line in lines) {
    line = line.trim();
    if (line.startsWith('## ')) {
      pushCurrent();
      currentDescription = null;
      currentImpact = null;

      // e.g. "## 1. Server Components & Surgical Hydration (`server-`)"
      final match = RegExp(r'^##\s+(\d+)\.\s+(.+)\s+\((.+)\)$').firstMatch(line);
      if (match != null) {
        currentPriority = int.parse(match.group(1)!);
        currentTitle = match.group(2)!.trim();
        var prefix = match.group(3)!.trim().replaceAll('`', '');
        if (prefix.endsWith('-')) {
          prefix = prefix.substring(0, prefix.length - 1);
        }
        currentPrefix = prefix;
      }
    } else if (line.startsWith('**Impact:**')) {
      currentImpact = line.replaceFirst('**Impact:**', '').trim();
    } else if (line.startsWith('**Description:**')) {
      currentDescription = line.replaceFirst('**Description:**', '').trim();
    }
  }
  pushCurrent();

  sections.sort((a, b) => a.priority.compareTo(b.priority));
  return sections;
}

Rule? _parseRule(File file) {
  final filename = file.uri.pathSegments.last;
  final id = filename.replaceFirst(RegExp(r'\.md$'), '');
  final raw = file.readAsStringSync();

  if (!raw.startsWith('---')) {
    print('Warning: $filename is missing YAML frontmatter');
    return null;
  }

  final endFrontmatter = raw.indexOf('---', 3);
  if (endFrontmatter == -1) {
    print('Warning: $filename has unclosed frontmatter');
    return null;
  }

  final yamlContent = raw.substring(3, endFrontmatter).trim();
  final body = raw.substring(endFrontmatter + 3).trim();

  String? title;
  String? impact;
  String? impactDescription;
  final tags = <String>[];

  for (final line in yamlContent.split('\n')) {
    final colonIndex = line.indexOf(':');
    if (colonIndex == -1) continue;
    final key = line.substring(0, colonIndex).trim();
    final value = line.substring(colonIndex + 1).trim();

    if (key == 'title') title = value;
    if (key == 'impact') impact = value;
    if (key == 'impactDescription') impactDescription = value;
    if (key == 'tags') {
      tags.addAll(value.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty));
    }
  }

  if (title == null || impact == null) {
    print('Warning: $filename is missing title or impact');
    return null;
  }

  return Rule(
    filename: filename,
    id: id,
    title: title,
    impact: impact,
    impactDescription: impactDescription,
    tags: tags,
    body: body,
  );
}

String _generateAgentsMd(List<Section> sections, List<Rule> rules) {
  final buffer = StringBuffer();
  buffer.writeln('# Jaspr Best Practices');
  buffer.writeln();
  buffer.writeln(
    'Comprehensive performance, architecture, and reliability guidelines for Jaspr applications, optimized for AI agents, LLMs, and automated workflows.',
  );
  buffer.writeln();
  buffer.writeln('---');
  buffer.writeln();
  buffer.writeln('## Table of Contents');
  buffer.writeln();

  for (final section in sections) {
    final sectionRules = rules.where((r) => r.id.startsWith('${section.prefix}-')).toList();
    if (sectionRules.isEmpty) continue;

    final sectionAnchor = _toAnchor('${section.priority} ${section.title}');
    buffer.writeln('${section.priority}. [${section.title}](#$sectionAnchor) (${section.impact})');
    for (var i = 0; i < sectionRules.length; i++) {
      final rule = sectionRules[i];
      final ruleAnchor = _toAnchor('${section.priority}.${i + 1} ${rule.title}');
      buffer.writeln('   - ${section.priority}.${i + 1} [${rule.title}](#$ruleAnchor)');
    }
  }

  buffer.writeln();
  buffer.writeln('---');
  buffer.writeln();

  for (final section in sections) {
    final sectionRules = rules.where((r) => r.id.startsWith('${section.prefix}-')).toList();
    if (sectionRules.isEmpty) continue;

    buffer.writeln('## ${section.priority}. ${section.title}');
    buffer.writeln();

    for (var i = 0; i < sectionRules.length; i++) {
      final rule = sectionRules[i];
      buffer.writeln('### ${section.priority}.${i + 1} ${rule.title}');

      // Extract content from body after the title header if present
      var content = rule.body;
      if (content.startsWith('## ')) {
        final newline = content.indexOf('\n');
        if (newline != -1) {
          content = content.substring(newline + 1).trim();
        }
      }

      buffer.writeln(content);
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }
  }

  return '${buffer.toString().trim()}\n';
}

String _generateSkillMd(List<Section> sections, List<Rule> rules) {
  final buffer = StringBuffer();
  buffer.writeln('---');
  buffer.writeln('name: jaspr-best-practices');
  buffer.writeln(
    'description: Comprehensive Jaspr performance and architecture guidelines. Covers Server Components, surgical hydration, bundle optimization, SSR data fetching, state management, and CSS-in-Dart patterns. Triggers when writing, reviewing, or refactoring Jaspr web components, pages, or full applications.',
  );
  buffer.writeln('---');
  buffer.writeln();
  buffer.writeln('# Jaspr Best Practices');
  buffer.writeln();
  buffer.writeln(
    'Comprehensive performance, architecture, and reliability guidelines for Jaspr web applications. Inspired by modern web engineering standards, this guide provides rules prioritized by impact to guide automated refactoring, code generation, and manual development.',
  );
  buffer.writeln();
  buffer.writeln('## When to Apply');
  buffer.writeln();
  buffer.writeln('Reference these guidelines when:');
  buffer.writeln('- Designing new Jaspr components, layouts, or pages');
  buffer.writeln('- Deciding between Server Components and Client Components (`@client`)');
  buffer.writeln('- Implementing server-side data fetching or client-side interactivity');
  buffer.writeln('- Optimizing bundle size, Time-to-Interactive (TTI), or Largest Contentful Paint (LCP)');
  buffer.writeln('- Writing or reviewing type-safe CSS-in-Dart styles with `@css`');
  buffer.writeln('- Refactoring existing Jaspr codebases for the latest features and patterns');
  buffer.writeln();
  buffer.writeln('## Rule Categories by Priority');
  buffer.writeln();
  buffer.writeln('| Priority | Category | Impact | Prefix | Description |');
  buffer.writeln('|---|---|---|---|---|');

  for (final section in sections) {
    buffer.writeln(
      '| ${section.priority} | ${section.title} | ${section.impact} | `${section.prefix}-` | ${section.description} |',
    );
  }

  buffer.writeln();
  buffer.writeln('---');
  buffer.writeln();
  buffer.writeln('## Quick Reference');
  buffer.writeln();

  for (final section in sections) {
    final sectionRules = rules.where((r) => r.id.startsWith('${section.prefix}-')).toList();
    if (sectionRules.isEmpty) continue;

    buffer.writeln('### ${section.priority}. ${section.title} (${section.impact})');
    buffer.writeln();
    for (final rule in sectionRules) {
      final desc = rule.impactDescription != null && rule.impactDescription!.isNotEmpty
          ? ' — ${rule.impactDescription}'
          : '';
      buffer.writeln('- [${rule.id}](rules/${rule.filename}) — ${rule.title}$desc.');
    }
    buffer.writeln();
  }

  buffer.writeln('---');
  buffer.writeln();
  buffer.writeln('## Detailed Rules Reference');
  buffer.writeln();
  buffer.writeln(
    'For an all-in-one compiled view of all rules complete with incorrect and correct code comparisons, see [AGENTS.md](AGENTS.md).',
  );
  buffer.writeln();

  return buffer.toString();
}

String _toAnchor(String text) {
  return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s_-]'), '').replaceAll(RegExp(r'\s'), '-');
}
