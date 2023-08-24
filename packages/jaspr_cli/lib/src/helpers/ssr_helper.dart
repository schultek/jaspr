import '../commands/base_command.dart';

mixin SsrHelper on BaseCommand {
  late final useSSR = () {
    return config.usesSsr;
  }();
}
