import 'package:jaspr/jaspr.dart';

class Hidden extends StatelessComponent {
  const Hidden({required this.hidden, required this.child, this.visibilityMode = false, Key? key}) : super(key: key);

  final bool hidden;
  final Component child;
  final bool visibilityMode;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield RenderScope(
      delegate: HiddenRenderDelegate(hidden, visibilityMode),
      child: child,
    );
  }
}

class HiddenRenderDelegate extends RenderDelegate {
  HiddenRenderDelegate(this.hidden, this.visibilityMode);

  final bool hidden;
  final bool visibilityMode;

  @override
  void renderNode(RenderElement node, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    super.renderNode(node, tag, id, classes, {...?styles, if (hidden && visibilityMode) 'visibility': 'hidden'},
        {...?attributes, if (hidden && !visibilityMode) 'hidden': ''}, events);
  }

  @override
  bool updateShouldNotify(covariant HiddenRenderDelegate oldDelegate) {
    return hidden != oldDelegate.hidden ||
        visibilityMode != oldDelegate.visibilityMode;
  }

}
