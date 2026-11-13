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

/// Matches one or more HTML ASCII whitespace characters that can separate class names.
final RegExp _htmlClassWhitespace = RegExp(r'[ \t\n\f\r]+');

/// Splits [classes] into individual class names, omitting empty entries.
///
/// Returns `null` when [classes] is `null` or contains no class names.
List<String>? _splitClasses(String? classes) {
  if (classes == null) return null;

  final classNames = classes.split(_htmlClassWhitespace).where((className) => className.isNotEmpty).toList();
  return classNames.isEmpty ? null : classNames;
}

typedef _AppliedParam = ({
  ApplyParams param,
  String? id,
  List<String>? classes,
  List<String>? styles,
  List<String>? attributes,
});

class DomElement extends DomRenderObjectElement {
  DomElement(DomComponent super.component);

  @override
  DomComponent get component => super.component as DomComponent;

  List<_AppliedParam>? _appliedParams;

  @override
  List<Component> buildOwnChildren() {
    return component.children ?? const [];
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
    _appliedParams = null;
    var id = component.id;
    var classes = component.classes;
    var styles = component.styles?.properties;
    var attributes = component.attributes;
    var events = component.events;

    if (inheritedDomParamsFor(renderObject) case final inheritedDomParams? when inheritedDomParams.isNotEmpty) {
      final classesSet = {...?_splitClasses(classes)};
      styles = Map.of(styles ?? {});
      attributes = Map.of(attributes ?? {});
      events = Map.of(events ?? {});

      for (final param in inheritedDomParams.reversed) {
        final String effectiveId = id ?? attributes['id'] ?? '';
        if (!param.target.matches(tag: component.tag, id: effectiveId, classes: classesSet)) {
          continue;
        }

        String? appliedId;
        List<String>? appliedClasses;
        List<String>? appliedStyles;
        List<String>? appliedAttributes;

        if (param.id case final paramId? when id == null) {
          id = paramId;
          appliedId = paramId;
        }

        if (param.classes case final paramClasses?) {
          for (final c in paramClasses) {
            if (classesSet.add(c)) {
              (appliedClasses ??= []).add(c);
            }
          }
        }

        if (param.styles case final stylesProps?) {
          for (final MapEntry(:key, :value) in stylesProps.entries) {
            if (!styles.containsKey(key)) {
              styles[key] = value;
              (appliedStyles ??= []).add(key);
            }
          }
        }

        if (param.attributes case final attributesMap?) {
          for (final MapEntry(:key, :value) in attributesMap.entries) {
            if (!attributes.containsKey(key)) {
              attributes[key] = value;
              (appliedAttributes ??= []).add(key);
            }
          }
        }

        if (param.events case final eventsMap?) {
          for (final MapEntry(:key, :value) in eventsMap.entries) {
            events[key] ??= value;
          }
        }

        if (appliedId != null || appliedClasses != null || appliedStyles != null || appliedAttributes != null) {
          (_appliedParams ??= []).add((
            param: param,
            id: appliedId,
            classes: appliedClasses,
            styles: appliedStyles,
            attributes: appliedAttributes,
          ));
        }
      }

      classes = classesSet.join(' ');
    }

    renderObject.update(id, classes, styles, attributes, events);
  }

  @internal
  String? computeAppliedDiff(bool Function(ApplyParams) isClientManaged) {
    final applied = _appliedParams;
    if (applied == null || applied.isEmpty) return null;

    final appliedClasses = <String>[];
    final appliedStyles = <String>[];
    final appliedAttributes = <String>[];
    String? appliedId;

    for (final entry in applied) {
      if (!isClientManaged(entry.param)) continue;

      if (entry.id case final id?) {
        appliedId = id;
      }
      if (entry.classes case final classes?) {
        appliedClasses.addAll(classes);
      }
      if (entry.styles case final styles?) {
        appliedStyles.addAll(styles);
      }
      if (entry.attributes case final attributes?) {
        appliedAttributes.addAll(attributes);
      }
    }

    if (appliedId != null || appliedClasses.isNotEmpty || appliedStyles.isNotEmpty || appliedAttributes.isNotEmpty) {
      final parts = <String>[];
      if (appliedId != null) {
        parts.add('i:${_escapeApplyValue(appliedId)}');
      }
      if (appliedClasses.isNotEmpty) {
        parts.add('c:${appliedClasses.map(_escapeApplyValue).join(',')}');
      }
      if (appliedStyles.isNotEmpty) {
        parts.add('s:${appliedStyles.map(_escapeApplyValue).join(',')}');
      }
      if (appliedAttributes.isNotEmpty) {
        parts.add('a:${appliedAttributes.map(_escapeApplyValue).join(',')}');
      }
      return parts.join(';');
    }
    return null;
  }
}

String _escapeApplyValue(String val) => (val.contains(';') || val.contains(',') || val.contains('%'))
    ? val.replaceAll('%', '%25').replaceAll(';', '%3B').replaceAll(',', '%2C')
    : val;

@internal
class ApplyDomComponent extends StatelessComponent implements DomComponent {
  const ApplyDomComponent({
    this.target = ApplyTarget.anyChild,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    required this.child,
    super.key,
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

  Map<String, dynamic> toMap() => {
    if (target != ApplyTarget.anyChild) 't': target.toMap(),
    if (id != null) 'i': id,
    if (classes != null) 'c': classes,
    if (styles?.properties case final s? when s.isNotEmpty) 's': s,
    if (attributes != null && attributes!.isNotEmpty) 'a': attributes,
  };

  @override
  Component build(BuildContext context) {
    return _InheritedDomComponent.merge(
      context,
      params: ApplyParams(
        target: target,
        id: id,
        classes: _splitClasses(classes),
        styles: styles?.properties,
        attributes: attributes,
        events: events,
        source: context as Element,
      ),
      child: child,
    );
  }
}

/// Which elements a [Component.apply] applies its properties to.
///
/// A target matches either the top-level elements of the apply's child
/// (those not nested in another of its elements) or the child's elements at any depth.
/// The [tag], [id], and [classes] filters narrow the matches further.
final class ApplyTarget {
  /// A target that matches all top-level elements of the apply's child.
  ///
  /// This is the default target of [Component.apply].
  static const ApplyTarget anyChild = ApplyTarget.childWith();

  /// Creates a target that matches the top-level elements of the apply's child
  /// with the given [tag], [id], and [classes].
  const ApplyTarget.childWith({
    this.tag,
    this.id,
    this.classes,
  }) : onlyChildren = true;

  /// Creates a target that matches the elements of the apply's child at any depth
  /// with the given [tag], [id], and [classes].
  const ApplyTarget.descendantWith({
    this.tag,
    this.id,
    this.classes,
  }) : onlyChildren = false;

  /// Whether this target only matches the top-level elements of the apply's child.
  final bool onlyChildren;

  /// The tag name an element must have to match, such as `div`, or `null` for any.
  final String? tag;

  /// The ID an element must have to match, or `null` for any.
  final String? id;

  /// The classes an element must all have to match, or `null` for any.
  final Set<String>? classes;

  @internal
  bool matches({required String tag, required String id, required Set<String> classes}) {
    if (this.tag case final expectedTag? when expectedTag != tag) return false;
    if (this.id case final expectedId? when expectedId != id) return false;
    if (this.classes case final expectedClasses? when !expectedClasses.every(classes.contains)) return false;
    return true;
  }

  Map<String, dynamic> toMap() => {
    if (!onlyChildren) 'd': true,
    if (tag != null) 't': tag,
    if (id != null) 'i': id,
    if (classes != null && classes!.isNotEmpty) 'c': classes!.toList(),
  };

  factory ApplyTarget.fromMap(Map<String, dynamic> map) {
    final onlyChildren = map['d'] != true;
    final tag = map['t'] as String?;
    final id = map['i'] as String?;
    final classes = (map['c'] as List?)?.cast<String>().toSet();
    if (onlyChildren) {
      return ApplyTarget.childWith(tag: tag, id: id, classes: classes);
    } else {
      return ApplyTarget.descendantWith(tag: tag, id: id, classes: classes);
    }
  }
}

@protected
abstract class DomRenderObjectElement extends MultiChildRenderObjectElement {
  DomRenderObjectElement(super.component);

  InheritedElement? _inheritedDomElement;

  @override
  void _updateInheritance() {
    final oldInheritedDomElement = _inheritedDomElement;
    super._updateInheritance();
    _inheritedDomElement = _inheritedElements?[_InheritedDomComponent];
    if (oldInheritedDomElement != _inheritedDomElement) {
      markNeedsRender();
    }
  }

  @override
  void activate() {
    super.activate();
    // Render again if reactivated where the inherited params differ,
    // such as when moved with a global key.
    if (_dirtyRender) markNeedsBuild();
  }

  @internal
  @protected
  DomParamsResolver? get inheritedDomResolver {
    if (_inheritedDomElement case final inheritedDomElement?) {
      final inheritedDomComponent = dependOnInheritedElement(inheritedDomElement) as _InheritedDomComponent;
      return inheritedDomComponent.resolveParams;
    }
    return null;
  }

  @internal
  List<ApplyParams>? inheritedDomParamsFor(RenderObject target) {
    return inheritedDomResolver?.call(target);
  }

  @internal
  @protected
  Component wrapWithInheritedDomComponent({
    required DomParamsResolver getParams,
    required Component child,
  }) {
    return _InheritedDomComponent(
      key: child.key == null ? null : ValueKey(child.key),
      resolveParams: getParams,
      child: child,
    );
  }

  List<Component> buildOwnChildren();

  @override
  List<Component> buildChildren() {
    return buildOwnChildren();
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
    this.source,
  });

  final ApplyTarget target;
  final String? id;
  final List<String>? classes;
  final Map<String, String>? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final Element? source;
}

typedef DomParamsResolver = List<ApplyParams> Function(RenderObject target);

bool _isDirectDomChild(RenderObject target, RenderObject? applyParent) {
  RenderObject? current = target;
  while (current != null) {
    if (current.parent == applyParent) {
      return true;
    }
    if (current.parent case final parent? when parent is RenderFragment) {
      current = parent;
    } else {
      break;
    }
  }
  return false;
}

class _InheritedDomComponent extends InheritedComponent {
  const _InheritedDomComponent({super.key, required this.resolveParams, required super.child});

  final DomParamsResolver resolveParams;

  factory _InheritedDomComponent.merge(
    BuildContext context, {
    required ApplyParams params,
    required Component child,
  }) {
    final parentResolver = context.dependOnInheritedComponentOfExactType<_InheritedDomComponent>()?.resolveParams;

    List<ApplyParams> resolveParams(RenderObject target) {
      final parentParams = parentResolver?.call(target) ?? const [];
      final applyParent = (context as Element)._parentRenderObjectElement?.renderObject;

      if (params.target.onlyChildren && !_isDirectDomChild(target, applyParent)) {
        return parentParams;
      }

      if (parentParams.isEmpty) {
        return [params];
      }

      return [...parentParams, params];
    }

    return _InheritedDomComponent(resolveParams: resolveParams, child: child);
  }

  @override
  bool updateShouldNotify(_InheritedDomComponent oldComponent) {
    return true;
  }
}

extension DomParamsElement on Element {
  @internal
  bool get hasInheritedDomParams => _inheritedElements?.containsKey(_InheritedDomComponent) ?? false;
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
