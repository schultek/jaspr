import 'dart:io';

import 'package:io/ansi.dart';
import 'package:jaspr_cli/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('getPubDevBaseUrl', () {
    test('returns custom mirror url if PUB_HOSTED_URL is set', () {
      final oldEnv = Platform.environment['PUB_HOSTED_URL'];
      try {
        // Since Platform.environment is unmodifiable, we can only reliably test this
        // by verifying it handles whatever is present or if we can run it.
        // But we can check that it returns either the mirror or the fallback.
        final url = getPubDevBaseUrl();
        if (oldEnv != null) {
          expect(url, equals(oldEnv));
        } else {
          expect(url, equals('https://pub.dev'));
        }
      } finally {}
    });
  });

  group('visualLength', () {
    test('calculates length excluding ANSI escape codes', () {
      expect(visualLength('hello'), equals(5));
      expect(visualLength('\x1b[31mred\x1b[0m'), equals(3));
      expect(visualLength('\\033[1mbold\\033[0m'), equals(4));
    });
  });

  group('wrapText', () {
    test('does not wrap short text fitting in maxWidth', () {
      expect(wrapText('hello world', 20), equals('hello world'));
    });

    test('wraps long text at space boundaries', () {
      expect(wrapText('hello world extra words', 12), equals('hello world\nextra words'));
    });

    test('indents subsequent wrapped lines with prefixLength', () {
      expect(wrapText('hello world extra words', 16, prefixLength: 4), equals('hello world\n    extra words'));
    });

    test('preserves empty lines', () {
      expect(wrapText('line1\n\nline2', 20), equals('line1\n\nline2'));
    });
  });

  group('wrapBox', () {
    test('wraps a message in a clean unicode box border', () {
      final box = wrapBox('Hello in box');
      expect(
        box,
        equals(
          '┌────────────────┐\n'
          '│  Hello in box  │\n'
          '└────────────────┘',
        ),
      );
    });

    test('supports centered text inside the box', () {
      final box = wrapBox('Short\nLongerLine', centerLines: true);
      expect(
        box,
        equals(
          '┌──────────────┐\n'
          '│    Short     │\n'
          '│  LongerLine  │\n'
          '└──────────────┘',
        ),
      );
    });

    test('supports colored borders', () {
      final box = wrapBox('Colored', borderColor: red);
      expect(
        box,
        equals(
          '${red.wrap('┌───────────┐')}\n'
          '${red.wrap('│')}  Colored  ${red.wrap('│')}\n'
          '${red.wrap('└───────────┘')}',
        ),
      );
    });

    test('respects IO overrides terminal columns if present', () {
      IOOverrides.runZoned(
        () {
          final words = List.generate(10, (_) => 'aaaaa').join(' ');
          final box = wrapBox(words);
          expect(
            box,
            equals(
              '┌─────────────────────────────────────────────┐\n'
              '│  aaaaa aaaaa aaaaa aaaaa aaaaa aaaaa aaaaa  │\n'
              '│  aaaaa aaaaa aaaaa                          │\n'
              '└─────────────────────────────────────────────┘',
            ),
          );
        },
        stdout: () => MockStdout(),
      );
    });
  });
}

class MockStdout implements Stdout {
  @override
  bool get hasTerminal => true;

  @override
  int get terminalColumns => 50;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
