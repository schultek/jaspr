import 'dart:async';

import 'package:jaspr_cli/src/command_runner.dart';
import 'package:jaspr_cli/src/commands/base_command.dart';
import 'package:jaspr_cli/src/helpers/print_logo.dart';
import 'package:test/test.dart';

class TestCommand extends BaseCommand {
  @override
  String get name => 'test';

  @override
  String get description => 'test description';

  @override
  Future<int> runCommand() async => 0;
}

void main() {
  group('PrintLogo', () {
    List<String> capturePrints(void Function() fn) {
      final prints = <String>[];
      runZoned(
        fn,
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => prints.add(line),
        ),
      );
      return prints;
    }

    test('does not print logo when printLogo is false in runner', () {
      final runner = JasprCommandRunner(false, false);
      final command = TestCommand();
      runner.addCommand(command);

      final output = capturePrints(() {
        command.printLogo(columns: 100);
      });

      expect(output, isEmpty);
    });

    test('prints mascot logo and wordmark when terminal columns >= 70', () {
      final runner = JasprCommandRunner(false, true);
      final command = TestCommand();
      runner.addCommand(command);

      final output = capturePrints(() {
        command.printLogo(columns: 70);
      });

      expect(output, isNotEmpty);
      // Mascot uses block characters
      expect(output.any((line) => line.contains('▄') || line.contains('▀')), isTrue);
      // Wordmark has JASPR art and CLI tagline
      expect(output.any((line) => line.contains('Jaspr CLI')), isTrue);
    });

    test('omits mascot logo on smaller terminals (< 70 columns)', () {
      final runner = JasprCommandRunner(false, true);
      final command = TestCommand();
      runner.addCommand(command);

      final output = capturePrints(() {
        command.printLogo(columns: 69);
      });

      expect(output, isNotEmpty);
      // Mascot should NOT be printed (mascot uses ▄ and ▀)
      expect(output.any((line) => line.contains('▄') || line.contains('▀')), isFalse);
      // Wordmark is still printed (uses █)
      expect(output.any((line) => line.contains('█')), isTrue);
      expect(output.any((line) => line.contains('Jaspr CLI')), isTrue);
    });

    test('prints compact text on very small terminals (< 45 columns)', () {
      final runner = JasprCommandRunner(false, true);
      final command = TestCommand();
      runner.addCommand(command);

      final output = capturePrints(() {
        command.printLogo(columns: 40);
      });

      expect(output, isNotEmpty);
      // Mascot should NOT be printed
      expect(output.any((line) => line.contains('▄') || line.contains('▀')), isFalse);
      // Big wordmark should NOT be printed
      expect(output.any((line) => line.contains('█')), isFalse);
      // Simple tagline is printed
      expect(output.any((line) => line.contains('Jaspr CLI')), isTrue);
    });
  });
}
