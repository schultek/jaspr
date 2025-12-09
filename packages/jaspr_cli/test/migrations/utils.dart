import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:file/file.dart';
import 'package:jaspr_cli/src/logging.dart';
import 'package:jaspr_cli/src/migrations/migration_models.dart';
import 'package:jaspr_cli/src/project.dart';
import 'package:test/test.dart';

void testUnitMigration(
  Migration migration, {
  required String input,
  Object? expectedOutput,
  Object? expectedMigrations,
  Object? expectedWarnings,
  List<String> features = const [],
}) {
  final result = parseString(content: input);

  final builder = EditBuilder(result.lineInfo);
  final reporter = MigrationReporter(builder);
  final context = MigrationUnitContext(result.unit, reporter, features);

  reporter.run(migration, context);

  final output = builder.apply(input);

  if (expectedOutput != null) {
    expect(output, expectedOutput, reason: 'Migration output did not match expected output');
  }

  if (expectedMigrations != null) {
    expect(reporter.migrations, expectedMigrations, reason: 'Migration reporter did not contain expected migrations');
  }
  if (expectedWarnings != null) {
    expect(reporter.warnings, expectedWarnings, reason: 'Migration reporter did not contain expected warnings');
  }
}

void testProjectMigration(
  Migration migration, {
  required FileSystem fs,
  List<String> directories = const ['lib'],
  Map<String, Object>? expectedMigrations,
  Map<String, Object>? expectedWarnings,
}) {
  final results = <MigrationResult>[];

  for (final dir in directories) {
    results.addAll(
      migration.runForDirectory(
        MigrationContext(
          fs.directory(dir),
          true,
          Project(Logger(false), fs: fs),
        ),
      ),
    );
  }

  if (expectedMigrations != null) {
    expect(results.where((r) => r.migrations.isNotEmpty), hasLength(expectedMigrations.length));

    for (final MapEntry(:key, :value) in expectedMigrations.entries) {
      final result = results.firstWhere((r) => r.path == key);
      expect(result.migrations, value, reason: 'Migrations for $key did not match expected migrations');
    }
  }

  if (expectedWarnings != null) {
    expect(results.where((r) => r.warnings.isNotEmpty), hasLength(expectedWarnings.length));

    for (final MapEntry(:key, :value) in expectedWarnings.entries) {
      final result = results.firstWhere((r) => r.path == key);
      expect(result.warnings, value, reason: 'Warnings for $key did not match expected warnings');
    }
  }
}

Matcher matchesMigration(Object description) {
  return isA<MigrationInstance>().having((i) => i.description, 'description', description);
}

Matcher matchesWarning(Object message) {
  return isA<MigrationWarning>().having((w) => w.message, 'message', message);
}
