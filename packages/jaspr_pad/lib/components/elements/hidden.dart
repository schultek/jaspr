import 'package:jaspr/jaspr.dart';

class Hidden extends StatelessComponent {
  const Hidden({required this.hidden, required this.child, this.visibilityMode = false, Key? key}) : super(key: key);

  final bool hidden;
  final Component child;
  final bool visibilityMode;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomBuilder.delegate(
      builder: HiddenBuilder(hidden, visibilityMode),
      child: child,
    );
  }
}

class HiddenBuilder extends DelegatingDomBuilder {
  HiddenBuilder(this.hidden, this.visibilityMode);

  final bool hidden;
  final bool visibilityMode;

  @override
  void renderNode(DomNode node, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    var hide = isDirectChild(node) && hidden;
    super.renderNode(node, tag, id, classes, {...?styles, if (hide && visibilityMode) 'visibility': 'hidden'},
        {...?attributes, if (hide && !visibilityMode) 'hidden': ''}, events);
  }

  @override
  bool updateShouldNotify(covariant HiddenBuilder oldBuilder) {
    return hidden != oldBuilder.hidden ||
        visibilityMode != oldBuilder.visibilityMode ||
        super.updateShouldNotify(oldBuilder);
  }

  @override
  bool shouldNotifyDependent(DomNode dependent) {
    return isDirectChild(dependent);
  }
}
