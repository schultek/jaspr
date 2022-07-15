import 'package:jaspr/jaspr.dart';
import 'package:jaspr/src/ui/utils.dart';
import 'package:jaspr/components.dart';

class TextField extends BaseElement {
  final String? label;
  final bool hidden;
  final String value;

  const TextField({
  this.label,
  this.hidden = false,
  this.value = "",
  super.key,
  super.id,
  super.style,
  super.classes,
  super.attributes,
  super.events,
}) : super(tag: 'input');

@override
Iterable<Component> build(BuildContext context) sync* {
  final String name = id ?? Utils.getRandomString(10);
  if (label != null) yield Label(child: Text(label!), attributes: {"for": name});
  yield Input(
    id: name,
    style: style,
    classes: getClasses(),
    attributes: {
      "name": name,
      "value": value,
      "type": hidden ? InputTypes.password.name : InputTypes.text.name,
      ...getAttributes(),
    },
    events: getEvents(),
  );
}
}
