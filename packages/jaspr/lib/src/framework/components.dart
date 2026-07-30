part of 'framework.dart';

/// Represents a html element in the DOM
///
/// Must have a [tag] and any number of [attributes].
/// Accepts a list of [children].
class DomComponent extends Component {
  const DomComponent._({
    super.key,
    required this.tag,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    this.children,
  });

  final String tag;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Element createElement() => DomElement(this);
}

typedef EventCallback = void Function(web.Event event);

class DomElement extends DomRenderObjectElement {
  DomElement(DomComponent super.component);

  @override
  DomComponent get component => super.component as DomComponent;

  @override
  List<Component> buildOwnChildren() {
    return component.children ?? const [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateRenderObject(renderObject as RenderElement);
  }

  @override
  void update(DomComponent newComponent) {
    assert(component.tag == newComponent.tag, 'Cannot update a DomComponent with a different tag.');
    super.update(newComponent);
  }

  @override
  bool shouldRerender(DomComponent newComponent) {
    return component.id != newComponent.id ||
        component.classes != newComponent.classes ||
        component.styles != newComponent.styles ||
        component.attributes != newComponent.attributes ||
        component.events != newComponent.events;
  }

  @override
  RenderObject createRenderObject() {
    final renderObject = _parentRenderObjectElement!.renderObject.createChildRenderElement(component.tag);
    assert(renderObject.parent == _parentRenderObjectElement!.renderObject);
    updateRenderObject(renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(RenderElement renderObject) {
    var id = component.id;
    var classes = component.classes;
    var styles = component.styles?.properties;
    var attributes = component.attributes;
    var events = component.events;

    if (inheritedDomParams case final inheritedDomParams?) {
      final classesSet = classes?.split(' ').toSet() ?? {};
      styles = Map.of(styles ?? {});
      attributes = Map.of(attributes ?? {});
      events = Map.of(events ?? {});

      for (final param in inheritedDomParams.reversed) {
        if (param.target.tag case final expectedTag? when expectedTag != component.tag) continue;
        if (param.target.id case final expectedId? when expectedId != id) continue;
        if (param.target.classes case final expectedClasses?
            when !expectedClasses.every((c) => classesSet.contains(c))) {
          continue;
        }

        id ??= param.id;

        if (param.classes case final paramClasses?) {
          classesSet.addAll(paramClasses);
        }

        if (param.styles case final stylesProps?) {
          for (final MapEntry(:key, :value) in stylesProps.entries) {
            styles[key] ??= value;
          }
        }

        if (param.attributes case final attributesMap?) {
          for (final MapEntry(:key, :value) in attributesMap.entries) {
            attributes[key] ??= value;
          }
        }

        if (param.events case final eventsMap?) {
          for (final MapEntry(:key, :value) in eventsMap.entries) {
            events[key] ??= value;
          }
        }
      }

      classes = classesSet.join(' ');
    }

    renderObject.update(id, classes, styles, attributes, events);
  }
}

class _ApplyDomComponent extends StatelessComponent implements DomComponent {
  const _ApplyDomComponent({
    this.target = ApplyTarget.anyChild,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    required this.child,
  });

  final ApplyTarget target;

  @override
  final String tag = '';
  @override
  final String? id;
  @override
  final String? classes;
  @override
  final Styles? styles;
  @override
  final Map<String, String>? attributes;
  @override
  final Map<String, EventCallback>? events;

  final Component child;
  @override
  List<Component>? get children => null;

  @override
  Component build(BuildContext context) {
    return _InheritedDomComponent.merge(
      context,
      params: ApplyParams(
        target: target,
        id: id,
        classes: classes?.split(' '),
        styles: styles?.properties,
        attributes: attributes,
        events: events,
      ),
      child: child,
    );
  }
}

/// Defines the target for a [Component.apply] component.
///
/// The target can select either a direct child or descendant,
/// and optionally filter by [tag], [id], and [classes].
final class ApplyTarget {
  static const ApplyTarget anyChild = ApplyTarget.childWith();

  const ApplyTarget.childWith({
    this.tag,
    this.id,
    this.classes,
  }) : onlyChildren = true;

  const ApplyTarget.descendantWith({
    this.tag,
    this.id,
    this.classes,
  }) : onlyChildren = false;

  final bool onlyChildren;
  final String? tag;
  final String? id;
  final Set<String>? classes;

  String get query => [
    if (onlyChildren) '> ',
    if (tag == null && id == null && classes == null)
      '*'
    else ...[
      ?tag,
      if (id != null) '#$id',
      if (classes case final classes?)
        for (final c in classes) '.$c',
    ],
  ].join();
}

@protected
abstract class DomRenderObjectElement extends MultiChildRenderObjectElement {
  DomRenderObjectElement(super.component);

  InheritedElement? _inheritedDomElement;

  List<ApplyParams>? get inheritedDomParams {
    if (_inheritedDomElement case final inheritedDomElement?) {
      final inheritedDomComponent = dependOnInheritedElement(inheritedDomElement) as _InheritedDomComponent;
      return inheritedDomComponent.params;
    }
    return null;
  }

  List<Component> buildOwnChildren();

  @override
  List<Component> buildChildren() {
    if (inheritedDomParams case final inheritedDomParams?) {
      final List<ApplyParams> newParams = inheritedDomParams.where((p) => !p.target.onlyChildren).toList();

      // If we either removed all selectors (or none), we can return the children as is.
      // The inherited element was already removed (or kept) by the [_updateInheritance] method.
      if (newParams.isEmpty || newParams.length == inheritedDomParams.length) {
        return buildOwnChildren();
      }

      return [
        for (final child in buildOwnChildren()) _InheritedDomComponent(params: newParams, child: child),
      ];
    }
    return buildOwnChildren();
  }

  @override
  void _updateInheritance() {
    super._updateInheritance();
    if (_inheritedElements case final originalInheritedElements?) {
      if (originalInheritedElements[_InheritedDomComponent] case final inheritedElement?) {
        final updatedInheritedElements = HashMap<Type, InheritedElement>.of(originalInheritedElements);
        _inheritedDomElement = inheritedElement;

        // Removing this here when *some* selectors use child combinators allows us to short-circuit the build logic to
        // not add a new [_InheritedDomComponent] when either:
        //   - *all* selectors use child combinators, as then the inherited element is already removed, or
        //   - *all* selectors use descendant combinators, as then the inherited element stays unchanged.
        // Only when *some* selectors use descendant combinators and *some* selectors use child combinators do we need
        // to create a new [_InheritedDomComponent] in the [buildChildren] method.
        if ((inheritedElement.component as _InheritedDomComponent).params.any((p) => p.target.onlyChildren)) {
          updatedInheritedElements.remove(_InheritedDomComponent);
        }

        _inheritedElements = updatedInheritedElements;
        return;
      }
    }
    _inheritedDomElement = null;
  }
}

@protected
class ApplyParams {
  const ApplyParams({
    required this.target,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
  });

  final ApplyTarget target;
  final String? id;
  final List<String>? classes;
  final Map<String, String>? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
}

class _InheritedDomComponent extends InheritedComponent {
  const _InheritedDomComponent({required this.params, required super.child});

  final List<ApplyParams> params;

  factory _InheritedDomComponent.merge(
    BuildContext context, {
    required ApplyParams params,
    required Component child,
  }) {
    final current = context.dependOnInheritedComponentOfExactType<_InheritedDomComponent>();
    if (current == null) {
      return _InheritedDomComponent(params: [params], child: child);
    }
    return _InheritedDomComponent(params: [...current.params, params], child: child);
  }

  @override
  bool updateShouldNotify(_InheritedDomComponent oldComponent) {
    if (identical(this, oldComponent)) return false;
    if (params.isEmpty && oldComponent.params.isEmpty) return false;
    return true;
  }
}

/// Represents a plain text node with no additional properties.
///
/// Styling is done through the parent element(s) and their styles.
class Text extends Component {
  const Text._(this.text, {super.key});

  final String text;

  @override
  Element createElement() => TextElement(this);
}

class TextElement extends LeafRenderObjectElement {
  TextElement(Text super.component);

  @override
  Text get component => super.component as Text;

  @override
  bool shouldRerender(Text newComponent) {
    return component.text != newComponent.text;
  }

  @override
  RenderObject createRenderObject() {
    final renderObject = _parentRenderObjectElement!.renderObject.createChildRenderText(component.text);
    assert(renderObject.parent == _parentRenderObjectElement!.renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(RenderText text) {
    text.update(component.text);
  }
}

/// A utility component that renders its [children] without any wrapper element.
///
/// This is meant to be used in places where you want to render multiple components,
/// but only a single component is allowed by the API.
class Fragment extends Component {
  const Fragment._(this.children, {super.key});

  const Fragment._empty({super.key}) : children = const [];

  final List<Component> children;

  @override
  Element createElement() => _FragmentElement(this);
}

class _FragmentElement extends MultiChildRenderObjectElement {
  _FragmentElement(Fragment super.component);

  @override
  List<Component> buildChildren() => (component as Fragment).children;

  @override
  RenderObject createRenderObject() {
    final renderObject = _parentRenderObjectElement!.renderObject.createChildRenderFragment();
    assert(renderObject.parent == _parentRenderObjectElement!.renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(RenderFragment fragment) {}
}
