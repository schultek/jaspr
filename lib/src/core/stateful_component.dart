part of core;

abstract class StatefulComponent implements Component {
  StatefulComponent({this.key});

  final String? key;

  @override
  Element createElement() => StatefulElement(this);

  State createState();
}

abstract class State<T extends StatefulComponent, U> {
  Iterable<Component> build(BuildContext context);

  T get component => _component!;
  T? _component;

  StatefulElement? _element;

  BuildContext get context => _element!;

  bool get mounted => _element != null;

  FutureOr<U?> preloadData() => null;

  @protected
  @mustCallSuper
  void initState(U? data) {}

  @mustCallSuper
  @protected
  void didUpdateComponent(covariant T oldComponent) {}

  @protected
  void setState(dynamic Function() fn) {
    fn();
    _element!.markNeedsBuild();
  }
}

class StatefulElement extends ComponentElement {
  StatefulElement(StatefulComponent component)
      : _state = component.createState(),
        super(component) {
    _state._component = component;
    _state._element = this;
  }

  @override
  StatefulComponent get _component => super._component as StatefulComponent;

  final State _state;
  State get state => _state;

  @override
  FutureOr<void> mount(Element? parent) async {
    await super.mount(parent);

    dynamic data;
    if (!kIsWeb) {
      data = await _state.preloadData();
      assert(data == null || _component.key != null);
      if (data != null) {
        var store = getInheritedComponentOfExactType<StateStore>();
        store?.saveState(_component.key!, data);
      }
    } else if (_component.key != null) {
      var store = getInheritedComponentOfExactType<StateStore>();
      data = store?.getState(_component.key!);
    }

    _state.initState(data);
  }

  @override
  void update(StatefulComponent newComponent) {
    super.update(newComponent);
    final StatefulComponent oldComponent = state._component!;
    _state._component = newComponent;
    state.didUpdateComponent(oldComponent);
  }

  @override
  Iterable<Component> build(BuildContext context) => _state.build(context);
}

class StateStore extends InheritedComponent {
  StateStore({required Component child}) : super(child: child);

  final Map<String, dynamic> _data = {};

  String write() {
    return jsonEncode(_data);
  }

  void parse(String s) {
    print("parse $s to ${jsonDecode(s)}");
    var data = jsonDecode(s);
    _data.addAll(data);
  }

  void saveState(String id, dynamic state) {
    _data[id] = state;
  }

  dynamic getState(String id) {
    return _data[id];
  }

  @override
  bool updateShouldNotify(StateStore oldWidget) => false;
}
