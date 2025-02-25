import 'dart:io';

import 'package:build_daemon/data/server_log.dart' as s;
import 'package:io/ansi.dart';
import 'package:logging/logging.dart' as l;
import 'package:mason/mason.dart' as m;
// ignore: implementation_imports
import 'package:webdev/src/logging.dart';

typedef Level = m.Level;

enum Tag {
  cli('CLI', cyan),
  builder('BUILDER', magenta),
  server('SERVER', yellow),
  flutter('FLUTTER', blue),
  none('', black);

  const Tag(this.name, this.color);
  final String name;
  final AnsiCode color;

  String format() {
    if (this == none) return '';
    return color.wrap('[$name] ')!;
  }
}

enum ProgressState { running, completed }

class Logger {
  Logger(this.verbose) {
    configureLogWriter(false, customLogWriter: (level, message, {loggerName, error, stackTrace}) {
      if (level.value < l.Level.INFO.value) return;

      if (!verbose && level.value < l.Level.SEVERE.value) return;

      // We log our own server and don't want to confuse the user.
      if (message.startsWith('Serving `web` on')) {
        return;
      }

      var buffer = StringBuffer(message);
      if (error != null) {
        buffer.writeln(error);
      }

      var log = buffer.toString().trim();
      if (log.isEmpty) {
        return;
      }
      write(log, tag: Tag.builder, level: level.toLevel());
    });
  }

  final bool verbose;

  final m.Logger logger = m.Logger();

  m.Progress? _progress;

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

  void write(String message, {Tag tag = Tag.cli, Level level = Level.info, ProgressState? progress}) {
    if (level == Level.verbose && !verbose) {
      return;
    }

    message = message.trim();
    if (message.contains('\n')) {
      var lines = message.split('\n');
      for (var l in lines) {
        write(l, tag: tag, level: level, progress: progress);
      }
      return;
    }

    var showAsProgress = !verbose && progress != null && (progress == ProgressState.running || _progress != null);

    String log = '${tag.format()}${level.format(message.trim())}';

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

const theme = m.LogTheme();

extension on Level {
  String format(String s) {
    return switch (this) {
      Level.verbose || Level.debug => theme.detail(s),
      Level.info => theme.info(s),
      Level.warning => theme.warn('[WARNing] $s'),
      Level.error => theme.err('[ERROR] $s'),
      Level.critical => theme.alert('[CRITICAL] $s'),
      Level.quiet => s,
    }!;
  }
}

extension on l.Level {
  Level toLevel() {
    if (value < l.Level.INFO.value) {
      return Level.debug;
    } else if (value < l.Level.WARNING.value) {
      return Level.info;
    } else if (value < l.Level.SEVERE.value) {
      return Level.warning;
    } else {
      return Level.error;
    }
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
