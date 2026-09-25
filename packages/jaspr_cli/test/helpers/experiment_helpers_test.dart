import 'package:args/command_runner.dart';
import 'package:jaspr_cli/src/commands/base_command.dart';
import 'package:jaspr_cli/src/helpers/experiment_helpers.dart';
import 'package:test/test.dart';

// Test command that exposes the experiment options.
class TestCommand extends BaseCommand {
  TestCommand({super.logger}) {
    addExperimentArgs();
  }

  @override
  String get name => 'test';

  @override
  String get description => 'Test command';

  late List<String> _experiments;
  late List<String> _args;

  @override
  Future<int> runCommand() async {
    _experiments = experiments;
    _args = experimentArgs;
    return 0;
  }

  List<String> get parsedExperiments => _experiments;
  List<String> get renderedArgs => _args;
}

void main() {
  late CommandRunner<int> runner;
  late TestCommand command;

  setUp(() {
    command = TestCommand();
    runner = CommandRunner<int>('jaspr', 'Test')..addCommand(command);
  });

  test('has no experiments by default', () async {
    await runner.run(['test']);

    expect(command.parsedExperiments, isEmpty);
    expect(command.renderedArgs, isEmpty);
  });

  test('takes one experiment', () async {
    await runner.run(['test', '--enable-experiment=primary-constructors']);

    expect(command.parsedExperiments, equals(['primary-constructors']));
    // The shape `build_runner`, the Dart VM and `dart compile` all take.
    expect(command.renderedArgs, equals(['--enable-experiment=primary-constructors']));
  });

  test('takes the option more than once', () async {
    await runner.run([
      'test',
      '--enable-experiment=primary-constructors',
      '--enable-experiment=macros',
    ]);

    expect(command.renderedArgs, equals(['--enable-experiment=primary-constructors', '--enable-experiment=macros']));
  });

  test('takes a comma separated list', () async {
    await runner.run(['test', '--enable-experiment=primary-constructors,macros']);

    expect(command.parsedExperiments, equals(['primary-constructors', 'macros']));
  });
}
