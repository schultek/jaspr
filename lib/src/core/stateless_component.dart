part of core;

abstract class StatelessComponent implements Component {
  Iterable<Component> build(BuildContext context);

  @override
  Element createElement() => StatelessElement(this);
}

class StatelessElement extends ComponentElement {
  StatelessElement(StatelessComponent component) : super(component);

  @override
  StatelessComponent get _component => super._component as StatelessComponent;

  @override
  Iterable<Component> build(BuildContext context) => _component.build(context);
}
