import '../commands/base_command.dart';

extension AddExperiments on BaseCommand {
  void addExperimentArgs() {
    argParser.addMultiOption(
      'enable-experiment',
      help:
          'Dart language experiments to enable, such as "primary-constructors".\n'
          'Passed on to `build_runner`, which applies them to the analysis Jaspr\'s builders do\n'
          'and to the web compilers, to the Dart command that runs or compiles the server,\n'
          'and to the compiler that generates the stylesheets.\n'
          'Pass several as a comma separated list, or by repeating the option.',
      valueHelp: 'experiment',
      splitCommas: true,
    );
  }

  /// The experiments named on the command line.
  List<String> get experiments => argResults!.multiOption('enable-experiment');

  /// The experiments as `--enable-experiment=<name>` flags, for `build_runner`
  /// and `dart compile`.
  ///
  /// Everything running inside `build_runner` reads the experiments from
  /// there: Jaspr's builders through the analyzer, and `build_web_compilers`
  /// for kernel, ddc, dart2js and dart2wasm.
  List<String> get experimentArgs => [
    for (final experiment in experiments) '--enable-experiment=$experiment',
  ];
}
