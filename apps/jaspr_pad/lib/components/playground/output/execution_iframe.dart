import 'package:jaspr/components.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../utils/node_reader.dart';
import 'execution_service.dart';
import 'execution_service.imports.dart';

class ExecutionIFrame extends StatelessComponent {
  const ExecutionIFrame({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomNodeReader(
      onNode: (node) {
        var iframe = context.read(iframeProvider);
        if (iframe == null || iframe != node) {
          context.read(iframeProvider.notifier).state = node as IFrameElementOrStubbed;
        }
      },
      child: iframe(
        id: 'frame',
        src: 'https://dartpad.dev/scripts/frame_dark.html',
        sandbox: 'allow-scripts allow-popups',
        attributes: {
          'flex': '',
        },
        [],
      ),
    );
  }
}
