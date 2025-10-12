import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:jaspr_cli/src/migrations/migration_models.dart';
import 'package:test/test.dart';

void testMigration(
  Migration migration, {
  required String input,
  Object? expectedOutput,
  Object? expectedMigrations,
  Object? expectedWarnings,
}) {
  final result = parseString(content: input);

  final builder = MigrationBuilder(result.lineInfo);
  final reporter = MigrationReporter(builder);

  reporter.run(migration, result.unit);

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
