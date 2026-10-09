import '../commands/base_command.dart';

extension AddExperiments on BaseCommand {
  void addExperimentArgs() {
    argParser.addMultiOption(
      'enable-experiment',
      help:
          'Dart language experiments to enable, such as "primary-constructors".\n'
          'Passed on to `build_runner`, which applies them to the analysis Jaspr\'s builders do\n'
          'and to the web compilers, and to the Dart command that runs or compiles the server.\n'
          'Pass several as a comma separated list, or by repeating the option.',
      valueHelp: 'experiment',
      splitCommas: true,
    );
  }

  /// The experiments named on the command line.
  List<String> get experiments => argResults!.multiOption('enable-experiment');

  /// The experiments as `--enable-experiment=<name>` flags.
  ///
  /// `build_runner` takes the same flag, and everything running inside it —
  /// Jaspr's builders through the analyzer, and `build_web_compilers` for
  /// kernel, ddc, dart2js and dart2wasm — reads the experiments from there. The
  /// Dart VM and `dart compile` take the flag in the same shape, which covers
  /// the server entrypoint.
  List<String> get experimentArgs => [
    for (final experiment in experiments) '--enable-experiment=$experiment',
  ];
}
