import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'execution_service.dart';

class ExecutionIFrame extends StatelessComponent {
  const ExecutionIFrame({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'iframe',
      id: 'frame',
      attributes: {
        'sandbox': 'allow-scripts allow-popups',
        'flex': '',
        'src': 'https://dartpad.dev/scripts/frame_dark.html',
      },
    );
  }

  @override
  Element createElement() => ExecutionIFrameElement(this);
}

class ExecutionIFrameElement extends StatelessElement {
  ExecutionIFrameElement(ExecutionIFrame component) : super(component);

  @override
  void render(DomBuilder b) {
    super.render(b);

    if (kIsWeb) {
      var element = (children.first as DomElement).source;
      var iframe = read(iframeProvider);
      if (iframe == null || iframe != element) {
        read(iframeProvider.notifier).state = element;
      }
    }
  }
}
