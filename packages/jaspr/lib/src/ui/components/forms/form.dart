import 'package:jaspr/src/ui/components/elements/base.dart';

class Form extends BaseElement {
  const Form({
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.children,
  }) : super(tag: 'form');
}

class Label extends BaseElement {
  const Label({
  super.key,
  super.id,
  super.style,
  super.classes,
  super.attributes,
  super.events,
  super.child,
  }) : super(tag: 'label');
}

enum InputTypes { text, password, radio, checkbox, file, submit, reset }

class Input extends BaseElement {
  const Input({
  super.key,
  super.id,
  super.style,
  super.classes,
  super.attributes,
  super.events,
  }) : super(tag: 'input');
}

