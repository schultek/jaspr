import 'dart:io';

import 'package:build_daemon/data/server_log.dart' as s;
import 'package:io/ansi.dart';
import 'package:mason/mason.dart' as m;
import 'package:meta/meta.dart';

typedef Level = m.Level;
typedef MasonLogger = m.Logger;

enum Tag {
  cli('CLI', cyan),
  builder('BUILDER', magenta),
  server('SERVER', yellow),
  flutter('FLUTTER', blue),
  client('CLIENT', lightGreen),
  none('', black);

  const Tag(this.name, this.color);
  final String name;
  final AnsiCode color;

  String format([bool daemon = false]) {
    if (this == none) return '';
    return color.wrap('[$name] ', forScript: daemon)!;
  }
}

enum ProgressState { running, completed }

abstract class Logger {
  Logger.base({this.verbose = false, this.logger});
  factory Logger(bool verbose) => _Logger(verbose: verbose);

  final MasonLogger? logger;
  final bool verbose;

  void complete(bool success);
  void write(String message, {Tag? tag, Level level = Level.info, ProgressState? progress}) {
    message = message.trimRight();

    if (message.contains('\n')) {
      final lines = message.split('\n');
      for (final l in lines) {
        writeLine(l, tag: tag, level: level, progress: progress);
      }
      return;
    }

    writeLine(message, tag: tag, level: level, progress: progress);
  }

  @protected
  void writeLine(String message, {Tag? tag, Level level = Level.info, ProgressState? progress}) {}
}

class _Logger extends Logger {
  _Logger({super.verbose = false}) : super.base(logger: MasonLogger());

  m.Progress? _progress;

  @override
  void complete(bool success) {
    if (_progress != null) {
      if (success) {
        _progress!.complete();
      } else {
        _progress!.fail();
      }
      _progress = null;
    }
  }

  @override
  void writeLine(String message, {Tag? tag, Level level = Level.info, ProgressState? progress}) {
    if (level == Level.verbose && !verbose) {
      return;
    }

    final showAsProgress = !verbose && progress != null && (progress == ProgressState.running || _progress != null);

    final String log = '${tag?.format() ?? ''}${level.format(message.trim())}';

    if (showAsProgress) {
      _progress ??= logger?.progress(log);
      if (progress == ProgressState.completed) {
        if (level.index <= Level.info.index) {
          _progress!.complete(log);
        } else {
          _progress!.fail(log);
        }
        _progress = null;
      } else {
        _progress!.update(log);
      }
    } else {
      if (_progress != null) {
        _progress!.cancel();
        _progress = null;
      }

      if (level.index >= Level.warning.index) {
        stderr.writeln(log);
      } else {
        stdout.writeln(log);
      }
    }
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

    write(log, tag: Tag.builder, level: level);

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
  String format(String s, [bool daemon = false]) {
    return switch (this) {
      Level.verbose || Level.debug => darkGray.wrap(s, forScript: daemon),
      Level.info => s,
      Level.warning => yellow.wrap(styleBold.wrap('[WARNING] $s', forScript: daemon), forScript: daemon),
      Level.error => lightRed.wrap('[ERROR] $s', forScript: daemon),
      Level.critical => backgroundRed.wrap(
        styleBold.wrap(white.wrap('[CRITICAL] $s', forScript: daemon), forScript: daemon),
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
