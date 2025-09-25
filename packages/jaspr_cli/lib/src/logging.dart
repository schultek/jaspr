import 'dart:io';

import 'package:build_daemon/data/server_log.dart' as s;
import 'package:io/ansi.dart';
import 'package:mason/mason.dart' as m;

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
  factory Logger(bool verbose) = _Logger;

  MasonLogger? get logger;
  bool get verbose;

  void complete(bool success);
  void write(String message, {Tag? tag, Level level = Level.info, ProgressState? progress});
}

class _Logger implements Logger {
  _Logger(this.verbose);

  @override
  final bool verbose;

  @override
  final MasonLogger logger = MasonLogger();

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
  void write(String message, {Tag? tag, Level level = Level.info, ProgressState? progress}) {
    if (level == Level.verbose && !verbose) {
      return;
    }

    message = message.trim();
    if (message.isEmpty) {
      return;
    }
    if (message.contains('\n')) {
      var lines = message.split('\n');
      for (var l in lines) {
        write(l, tag: tag, level: level, progress: progress);
      }
      return;
    }

    var showAsProgress = !verbose && progress != null && (progress == ProgressState.running || _progress != null);

    String log = '${tag?.format() ?? ''}${level.format(message.trim())}';

    if (showAsProgress) {
      _progress ??= logger.progress(log);
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
    if (!verbose) return;
    //if (serverLog.level < Level.INFO) return;

    var buffer = StringBuffer(serverLog.message);
    if (serverLog.error != null) {
      buffer.writeln(serverLog.error);
    }

    var log = buffer.toString();
    if (log.trim().isEmpty) {
      return;
    }

    write(log, tag: Tag.builder, level: serverLog.level.toLevel());
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
    if (this < s.Level.INFO) {
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
