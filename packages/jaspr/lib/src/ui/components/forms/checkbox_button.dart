import 'package:jaspr/jaspr.dart';
import 'package:jaspr/src/ui/utils.dart';
import 'package:jaspr/components.dart';

class CheckboxButton extends BaseElement {
    final String? label;
    final String group;
    final bool checked;
    final String value;

    const CheckboxButton({
    this.label,
    required this.group,
    required this.value,
    this.checked = false,
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
    yield Input(
      id: name,
      style: style,
      classes: getClasses(),
      attributes: {
        "name": group,
        "value": value,
        "type": InputTypes.checkbox.name,
        if (checked) "checked": "checked",
        ...getAttributes(),
      },
      events: getEvents(),
    );
    if (label != null) yield Label(child: Text(label!), attributes: {"for": name});
  }
}
