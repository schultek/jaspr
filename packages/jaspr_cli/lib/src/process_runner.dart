import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

/// A class that handles running processes, allowing for mocking in tests.
class ProcessRunner {
  const ProcessRunner();

  static const _zoneKey = Symbol('ProcessRunner');

  /// Returns the current [ProcessRunner] configured in the current zone,
  /// or the default [ProcessRunner] if none is configured.
  static ProcessRunner get instance {
    return async.Zone.current[_zoneKey] as ProcessRunner? ?? const ProcessRunner();
  }

  static bool get isDefault {
    return async.Zone.current[_zoneKey] == null;
  }

  /// Runs [body] in a zone with the given [processRunner].
  static R runZoned<R>(R Function() body, ProcessRunner processRunner) {
    return async.runZoned(body, zoneValues: {_zoneKey: processRunner});
  }

  /// Starts a process.
  Future<Process> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) {
    return Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      mode: mode,
    );
  }

  /// Runs a process successfully.
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) {
    return Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      stdoutEncoding: stdoutEncoding,
      stderrEncoding: stderrEncoding,
    );
  }

  /// Runs a process synchronously.
  ProcessResult runSync(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) {
    return Process.runSync(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      stdoutEncoding: stdoutEncoding,
      stderrEncoding: stderrEncoding,
    );
  }
}
