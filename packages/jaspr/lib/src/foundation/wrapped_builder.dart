import 'package:domino/domino.dart';

class WrappedDomBuilder extends DomBuilder {
  WrappedDomBuilder(this.builder);

  final DomBuilder builder;

  @override
  void open(
    String tag, {
    String? key,
    String? id,
    Iterable<String>? classes,
    Map<String, String>? styles,
    Map<String, String>? attributes,
    Map<String, DomEventFn>? events,
    DomLifecycleEventFn? onCreate,
    DomLifecycleEventFn? onUpdate,
    DomLifecycleEventFn? onRemove,
  }) {
    builder.open(
      tag,
      key: key,
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      onCreate: onCreate,
      onUpdate: onUpdate,
      onRemove: onRemove,
    );
  }

  @override
  dynamic close({String? tag}) => builder.close(tag: tag);

  @override
  void innerHtml(String value) => builder.innerHtml(value);

  @override
  void skipNode() => builder.skipNode();

  @override
  void skipRemainingNodes() => builder.skipRemainingNodes();

  @override
  void text(String value) => builder.text(value);
}
