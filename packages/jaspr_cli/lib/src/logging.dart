import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:build_daemon/data/server_log.dart' as s;
import 'package:io/ansi.dart';
import 'package:mason/mason.dart' as m;

import 'utils.dart';

typedef Level = m.Level;

enum Tag {
  cli('LOG', 'L', darkGray, backgroundDarkGray, white),
  builder('BUILDER', 'B', magenta, backgroundMagenta, white),
  server('SERVER', 'S', yellow, backgroundYellow, black),
  flutter('FLUTTER', 'F', blue, backgroundBlue, white),
  client('CLIENT', 'C', lightGreen, backgroundGreen, black),
  css('STYLES', 'Y', cyan, backgroundCyan, black),
  none('', '', black, backgroundBlack, black);

  const Tag(this.name, this.char, this.color, this.backgroundColor, this.textColor);
  final String name;
  final String char;
  final AnsiCode color;
  final AnsiCode backgroundColor;
  final AnsiCode textColor;

  String format([bool daemon = false, bool verbose = false]) {
    if (this == none) return '';
    final nameStr = verbose ? name.padRight(7, ' ') : char;
    if (!daemon && !ansiOutputEnabled) {
      return '[$nameStr] ';
    }
    return '${backgroundColor.wrap(
      textColor.wrap(styleBold.wrap(' $nameStr ', forScript: daemon)!, forScript: daemon)!,
      forScript: daemon,
    )!} ';
  }
}

enum ProgressState { running, completed }

abstract class Logger {
  Logger.base({this.verbose = false});
  factory Logger(bool verbose) => _Logger(verbose: verbose);

  final bool verbose;

  void complete(bool success);
  void write(String message, {Tag tag = Tag.none, Level level = Level.info, ProgressState? progress});

  // Custom interactive prompting
  Future<String> prompt(String message, {String? defaultValue});
  Future<bool> confirm(String message, {bool defaultValue = false, String? hint});
  Future<T> chooseOne<T>(String message, {required List<T> choices, String Function(T)? display});

  // Persistent footer methods
  void setFooter(List<String> lines);
  void clearFooter();

  static (String, int) formatMessage(
    String message,
    Tag? tag,
    Level level, {
    bool verbose = false,
    bool daemon = false,
  }) {
    final buffer = StringBuffer();

    final tagPrefix = tag?.format(daemon, verbose) ?? '';
    final levelPrefix = level.tag;

    final prefix =
        '$tagPrefix'
        '${levelPrefix.isNotEmpty ? level.format(levelPrefix, daemon: daemon) : ''}';
    final prefixLength = visualLength(tagPrefix) + (levelPrefix.isNotEmpty ? 2 : 0);

    final lines = message.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      buffer.write(i == 0 ? prefix : (' ' * prefixLength));
      buffer.write(level.format(line.trimRight(), daemon: daemon));
      if (i < lines.length - 1) {
        buffer.writeln();
      }
    }

    return (buffer.toString(), prefixLength);
  }
}

class _Logger extends Logger {
  _Logger({super.verbose = false}) : super.base();

  // Persistent footer lines
  final List<String> _footerLines = [];

  late final _Progress _progress = _Progress(this);

  StreamQueue<List<int>> get _queue => _stdinQueue ??= StreamQueue(stdin);
  StreamQueue<List<int>>? _stdinQueue;
  final List<int> _byteBuffer = [];

  Future<int> _readByte() async {
    if (_byteBuffer.isEmpty) {
      final chunk = await _queue.next;
      _byteBuffer.addAll(chunk);
    }
    return _byteBuffer.removeAt(0);
  }

  void _clearFooterSpace() {
    if (stdout.hasTerminal && _footerLines.isNotEmpty) {
      stdout.write('\x1b[${_footerLines.length}A\r\x1b[J');
    }
  }

  void _drawFooterSpace() {
    if (stdout.hasTerminal && _footerLines.isNotEmpty) {
      for (final line in _footerLines) {
        stdout.writeln(line);
      }
    }
  }

  @override
  void setFooter(List<String> lines) {
    if (_footerLines.join('\n') == lines.join('\n')) return;

    _clearFooterSpace();
    _footerLines.clear();
    _footerLines.addAll(lines);
    _drawFooterSpace();
  }

  @override
  void clearFooter() {
    if (_footerLines.isEmpty) return;
    _clearFooterSpace();
    _footerLines.clear();
  }

  @override
  void complete(bool success) {
    if (_progress.isActive) {
      _progress.complete(_progress.current?.$1 ?? '', _progress.current!.$2, _progress.current!.$3, success);
    }
  }

  @override
  void write(String message, {Tag tag = Tag.none, Level level = Level.info, ProgressState? progress}) {
    if (level == Level.verbose && !verbose) {
      return;
    }

    message = message.trimRight();

    final (content, prefixLength) = Logger.formatMessage(message, tag, level, verbose: verbose);

    if (!stdout.hasTerminal) {
      if (content.trim().isEmpty) return;
      if (level.index >= Level.error.index) {
        stderr.writeln(content);
      } else {
        stdout.writeln(content);
      }

      final wasRunning = _progress.isActive && _progress.current?.$2 == tag;

      if (!verbose && progress == ProgressState.completed && wasRunning) {
        _progress.complete(content, tag, level, level.index <= Level.info.index);
      } else if (!verbose && progress == ProgressState.running) {
        _progress.update(content, tag, level);
      }
      return;
    }

    final maxWidth = math.max(20, stdout.terminalColumns - (progress != null ? 4 : 0));
    var wrappedContent = wrapText(content, maxWidth, prefixLength: prefixLength);

    if (wrappedContent.isEmpty && progress == ProgressState.running) {
      return;
    }

    if (progress == ProgressState.running && !verbose && level.index < Level.error.index) {
      if (wrappedContent.contains('\n')) {
        var firstLine = wrappedContent.split('\n').first.trimRight();
        if (!firstLine.endsWith('...')) {
          if (visualLength(firstLine) + 3 > maxWidth) {
            firstLine = firstLine.substring(0, math.max(0, firstLine.length - 3));
          }
          firstLine = '$firstLine...';
        }
        wrappedContent = firstLine;
      }
    }

    final bool shouldReplace =
        !verbose &&
        _progress.isActive &&
        tag == _progress.current!.$2 &&
        _progress.current!.$3.index < Level.error.index;

    if (shouldReplace) {
      if (progress == ProgressState.running) {
        _progress.update(wrappedContent, tag, level);
      } else if (progress == ProgressState.completed) {
        _progress.complete(wrappedContent, tag, level, level.index <= Level.info.index);
      } else {
        _replaceLines(wrappedContent, _progress.current!.$1.split('\n').length);
        _progress.clear();
      }
      return;
    }

    if (_progress.isActive) {
      _progress.suspend();
    }

    if (!verbose && progress == ProgressState.running) {
      _progress.update(wrappedContent, tag, level);
    } else {
      _clearFooterSpace();
      if (level.index >= Level.error.index) {
        stderr.writeln(wrappedContent);
      } else {
        stdout.writeln(wrappedContent);
      }
      _drawFooterSpace();
    }
  }

  void _replaceLines(String newContent, int previousLinesCount) {
    if (stdout.hasTerminal) {
      final totalUp = _footerLines.length + previousLinesCount;
      stdout.write('\x1b[${totalUp}A\r\x1b[J');
      stdout.writeln(newContent);
      _drawFooterSpace();
    }
  }

  Future<String?> _readLine() async {
    if (!stdin.hasTerminal) {
      return stdin.readLineSync();
    }

    final bytes = <int>[];
    while (true) {
      final byte = await _readByte();
      if (byte == 13 || byte == 10) {
        if (byte == 13) {
          if (_byteBuffer.isNotEmpty && _byteBuffer.first == 10) {
            _byteBuffer.removeAt(0);
          }
        }
        break;
      }
      bytes.add(byte);
    }
    return utf8.decode(bytes);
  }

  @override
  Future<String> prompt(String message, {String? defaultValue}) async {
    _clearFooterSpace();
    final suffix = defaultValue != null ? darkGray.wrap(' (${styleBold.wrap(defaultValue)})')! : '';
    stdout.write('${cyan.wrap(styleBold.wrap('?'))} ${styleBold.wrap(message) ?? message}$suffix ');
    final input = (await _readLine())?.trim();
    if (input == null || input.isEmpty) {
      if (defaultValue != null) {
        if (stdout.hasTerminal) {
          stdout.write(
            '\x1b[1A\r\x1b[2K${cyan.wrap(styleBold.wrap('?'))} ${styleBold.wrap(message) ?? message} ${cyan.wrap(defaultValue)}\n',
          );
        }
        _drawFooterSpace();
        return defaultValue;
      }
      _drawFooterSpace();
      return prompt(message, defaultValue: defaultValue);
    }
    if (stdout.hasTerminal) {
      stdout.write(
        '\x1b[1A\r\x1b[2K${cyan.wrap(styleBold.wrap('?'))} ${styleBold.wrap(message) ?? message} ${cyan.wrap(input)}\n',
      );
    }
    _drawFooterSpace();
    return input;
  }

  @override
  Future<bool> confirm(String message, {bool defaultValue = false, String? hint}) async {
    _clearFooterSpace();
    final suffix = defaultValue
        ? darkGray.wrap('[${styleBold.wrap('Y')}/n]')!
        : darkGray.wrap('[y/${styleBold.wrap('N')}]')!;
    final printedPrompt = '${cyan.wrap(styleBold.wrap('?'))} ${styleBold.wrap(message) ?? message} $suffix ';

    if (stdout.hasTerminal && hint != null) {
      stdout.write(printedPrompt);
      stdout.write('\n  ${darkGray.wrap(styleBold.wrap(hint))}');
      final ansiRegex = RegExp(r'\x1b\[[0-9;]*[a-zA-Z]');
      final visualPromptLength = printedPrompt.replaceAll(ansiRegex, '').length;
      stdout.write('\x1b[1A\r\x1b[${visualPromptLength}C');
    } else {
      stdout.write(printedPrompt);
      if (hint != null) {
        stdout.write('\n  ${darkGray.wrap(styleBold.wrap(hint))}\n');
      }
    }

    final input = (await _readLine())?.trim().toLowerCase();

    final bool result;
    if (input == null || input.isEmpty) {
      result = defaultValue;
    } else {
      result = input == 'y' || input == 'yes';
    }

    final resultText = result ? 'Yes' : 'No';

    if (stdout.hasTerminal) {
      if (hint != null) {
        stdout.write('\x1b[1A\r\x1b[J');
      } else {
        stdout.write('\x1b[1A\r\x1b[2K');
      }
      stdout.write(
        '${cyan.wrap(styleBold.wrap('?'))} ${styleBold.wrap(message) ?? message} ${cyan.wrap(resultText)}\n',
      );
    }
    _drawFooterSpace();

    return result;
  }

  @override
  Future<T> chooseOne<T>(String message, {required List<T> choices, String Function(T)? display}) async {
    display ??= (o) => o.toString();

    _clearFooterSpace();
    if (!stdin.hasTerminal) {
      _drawFooterSpace();
      return choices.first;
    }

    stdout.writeln('${cyan.wrap(styleBold.wrap('?'))} ${styleBold.wrap(message) ?? message}');
    int selectedIndex = 0;

    void printChoices() {
      for (int i = 0; i < choices.length; i++) {
        final isSelected = i == selectedIndex;
        final prefix = isSelected ? '  ❯ ' : '    ';
        final optionText = display!(choices[i]);
        if (isSelected) {
          stdout.writeln(cyan.wrap(styleBold.wrap('$prefix$optionText')));
        } else {
          stdout.writeln('$prefix$optionText');
        }
      }
    }

    printChoices();

    final originalLineMode = stdin.lineMode;
    final originalEchoMode = stdin.echoMode;
    try {
      stdin.lineMode = false;
      stdin.echoMode = false;

      while (true) {
        final bytes = await _readByte();
        // Carriage Return (13) or Line Feed (10) represents the Enter key to confirm selection.
        if (bytes == 13 || bytes == 10) {
          break;
        }

        // Escape sequence (27) indicates the start of an ANSI escape sequence (e.g. arrow keys).
        if (bytes == 27) {
          final b2 = await _readByte();
          if (b2 == 91) {
            // '[' character
            final b3 = await _readByte();
            if (b3 == 65) {
              // 'A' represents the Up Arrow key
              selectedIndex = (selectedIndex - 1 + choices.length) % choices.length;
            } else if (b3 == 66) {
              // 'B' represents the Down Arrow key
              selectedIndex = (selectedIndex + 1) % choices.length;
            }
          }
        }

        stdout.write('\x1b[${choices.length}A');
        printChoices();
      }
    } finally {
      stdin.lineMode = originalLineMode;
      stdin.echoMode = originalEchoMode;
    }

    // Clear printed options and rewrite the prompt with the selected choice
    stdout.write('\x1b[${choices.length + 1}A\r\x1b[J');
    stdout.writeln(
      '${cyan.wrap(styleBold.wrap('?'))} ${styleBold.wrap(message) ?? message} ${cyan.wrap(display(choices[selectedIndex]))}',
    );
    _drawFooterSpace();

    return choices[selectedIndex];
  }
}

extension ServerLogger on Logger {
  void writeServerLog(s.ServerLog serverLog) {
    final level = serverLog.level.toLevel();
    if (!verbose && level.index < Level.info.index) return;

    final buffer = StringBuffer(serverLog.message);
    if (serverLog.error != null) {
      buffer.writeln(serverLog.error);
    }

    final log = buffer.toString().trim();
    if (log.isEmpty) {
      return;
    }

    write(
      log,
      tag: Tag.builder,
      level: verbose && level == Level.info ? Level.verbose : level,
      progress: !verbose ? ProgressState.running : null,
    );

    if (log.startsWith('build_web_compilers:entrypoint') &&
        log.contains('transitive libraries have sdk dependencies that not supported on this platform') &&
        log.contains('flutter|lib')) {
      write(
        'Failed to compile some libraries with a dependency on the Flutter SDK. Try setting `jaspr.flutter` to `plugins` in your `pubspec.yaml` file.',
        tag: Tag.cli,
        level: Level.error,
      );
    }
  }
}

extension LevelFormat on Level {
  String get tag {
    return switch (this) {
      Level.warning => '[WARNING] ',
      Level.error => '[ERROR] ',
      Level.critical => '[CRITICAL] ',
      _ => '',
    };
  }

  String format(String s, {bool daemon = false, bool initialLine = true}) {
    return switch (this) {
      Level.verbose || Level.debug => darkGray.wrap(s, forScript: daemon),
      Level.info => s,
      Level.warning => yellow.wrap(styleBold.wrap(s, forScript: daemon), forScript: daemon),
      Level.error => lightRed.wrap(styleBold.wrap(s, forScript: daemon), forScript: daemon),
      Level.critical => backgroundRed.wrap(
        styleBold.wrap(white.wrap(s, forScript: daemon), forScript: daemon),
        forScript: daemon,
      ),
      Level.quiet => s,
    }!;
  }
}

extension on s.Level {
  Level toLevel() {
    if (this < s.Level.CONFIG) {
      return Level.verbose;
    } else if (this < s.Level.INFO) {
      return Level.debug;
    } else if (this < s.Level.WARNING) {
      return Level.info;
    } else if (this < s.Level.SEVERE) {
      return Level.warning;
    } else {
      return Level.error;
    }
  }
}

class _Progress {
  final _Logger _logger;

  (String, Tag, Level)? current;
  Stopwatch? stopwatch;
  int spinnerIndex = 0;
  Timer? spinnerTimer;

  static const List<String> _spinnerChars = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

  _Progress(this._logger);

  bool get isActive => current != null;

  void clear() {
    spinnerTimer?.cancel();
    spinnerTimer = null;
    current = null;
  }

  void update(String message, Tag tag, Level level) {
    final prevLinesCount = current?.$1.split('\n').length ?? 0;
    final wasActive = isActive;
    current = (message, tag, level);

    if (stopwatch == null) {
      stopwatch = Stopwatch()..start();
    } else {
      stopwatch!.start();
    }

    if (stdout.hasTerminal) {
      // Immediately draw the updated message
      final spinnerChar = _spinnerChars[spinnerIndex];
      final lineContent = '$message ${cyan.wrap(spinnerChar)}';

      if (wasActive) {
        _logger._replaceLines(lineContent, prevLinesCount);
      } else {
        _logger._clearFooterSpace();
        stdout.writeln(lineContent);
        _logger._drawFooterSpace();
      }

      spinnerTimer ??= Timer.periodic(const Duration(milliseconds: 80), (_) {
        if (current?.$1 case final message?) {
          spinnerIndex = (spinnerIndex + 1) % _spinnerChars.length;

          final spinnerChar = _spinnerChars[spinnerIndex];
          final lineContent = '$message ${cyan.wrap(spinnerChar)}';
          _logger._replaceLines(lineContent, message.split('\n').length);
        }
      });
    }
  }

  void suspend() {
    if (stdout.hasTerminal && current != null) {
      _logger._replaceLines(current!.$1, current!.$1.split('\n').length);
    }
    clear();
    stopwatch?.stop();
  }

  void complete(String message, Tag tag, Level level, bool success) {
    final prevLinesCount = current?.$1.split('\n').length ?? 0;
    current = (message, tag, level);

    final statusSymbol = success ? green.wrap('✓') : red.wrap('✗');

    String timeStr = '';
    if (stopwatch != null) {
      final elapsed = stopwatch!.elapsed;
      final seconds = elapsed.inMilliseconds / 1000.0;
      timeStr = ' ${darkGray.wrap('(${seconds.toStringAsFixed(1)}s)')}';
    }

    final lineContent = '$message $statusSymbol$timeStr';

    if (stdout.hasTerminal) {
      _logger._replaceLines(lineContent, prevLinesCount);
    } else {
      stdout.writeln(lineContent);
    }

    clear();
    stopwatch?.stop();
    stopwatch = null;
  }
}
