import '../helpers/new_component.dart';
import '../helpers/new_page.dart';
import 'base_command.dart';

class NewCommand extends BaseCommand {
  NewCommand({super.logger}) {
    addSubcommand(NewComponentCommand(logger: logger));
    addSubcommand(NewPageCommand(logger: logger));
  }

  @override
  String get invocation {
    return 'jaspr new <subcommand> [arguments]';
  }

  @override
  String get description => 'Create a new Jaspr component.';

  @override
  String get name => 'new';

  @override
  String get category => 'Project';

  @override
  Future<int> runCommand() async {
    // if no subcommand is provided, show usage
    usageException('Please specify a subcommand.');
  }
}
