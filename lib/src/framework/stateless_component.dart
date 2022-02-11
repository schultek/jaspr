part of framework;

abstract class StatelessComponent extends Component {
  const StatelessComponent({Key? key}) : super(key: key);

  Iterable<Component> build(BuildContext context);

  @override
  Element createElement() => StatelessElement(this);
}

class StatelessElement extends MultiChildElement {
  StatelessElement(StatelessComponent component) : super(component);

  @override
  StatelessComponent get component => super.component as StatelessComponent;

  @override
  void update(StatelessComponent newComponent) {
    super.update(newComponent);
    _dirty = true;
    root.performRebuildOn(this);
  }

  @override
  Iterable<Component> build() => component.build(this);
}
