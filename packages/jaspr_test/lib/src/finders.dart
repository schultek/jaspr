import 'package:jaspr/jaspr.dart';

import 'all_elements.dart';

/// Signature for [CommonFinders.byComponentPredicate].
typedef ComponentPredicate = bool Function(Component component);

/// Signature for [CommonFinders.byElementPredicate].
typedef ElementPredicate = bool Function(Element element);

/// Some frequently used component [Finder]s.
const CommonFinders find = CommonFinders._();

/// Provides lightweight syntax for getting frequently used component [Finder]s.
///
/// This class is instantiated once, as [find].
class CommonFinders {
  const CommonFinders._();

  /// Finds [DomComponent] components with a tag equal to the `tag` argument.
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// expect(find.tag('p'), findsOneComponent);
  /// ```
  ///
  /// This will match paragraph dom elements.
  Finder tag(String tag) => _TagFinder(tag);

  /// Finds [Text] components containing string equal to the `text` argument.
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// expect(find.text('Back'), findsOneComponent);
  /// ```
  ///
  /// This will match [Text] components that contain the "Back" string.
  Finder text(String text) => _TextFinder(text);

  /// Finds [Text] components which contain the given `pattern` argument.
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// expect(find.textContain('Back'), findsOneComponent);
  /// expect(find.textContain(RegExp(r'(\w+)')), findsOneComponent);
  /// ```
  Finder textContaining(Pattern pattern) => _TextContainingFinder(pattern);

  /// Looks for components that contain a [Text] descendant with `text`
  /// in it.
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// // Suppose you have a button with text 'Update' in it:
  /// Button(
  ///   child: Text('Update')
  /// )
  ///
  /// // You can find and tap on it like this:
  /// tester.tap(find.componentWithText(Button, 'Update'));
  /// ```
  Finder componentWithText(Type componentType, String text) {
    return find.ancestor(of: find.text(text), matching: find.byType(componentType));
  }

  /// Finds components by searching for one with a particular [Key].
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// expect(find.byKey(backKey), findsOneComponent);
  /// ```
  Finder byKey(Key key, {bool skipOffstage = true}) => _KeyFinder(key);

  /// Finds components by searching for components with a particular type.
  ///
  /// This does not do subclass tests, so for example
  /// `byType(StatefulComponent)` will never find anything since that's
  /// an abstract class.
  ///
  /// The `type` argument must be a subclass of [Component].
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// expect(find.byType(IconButton), findsOneComponent);
  /// ```
  Finder byType(Type type) => _ComponentTypeFinder(type);

  /// Finds components by searching for elements with a particular type.
  ///
  /// This does not do subclass tests, so for example
  /// `byElementType(Element)` will never find anything
  /// since that's an abstract class.
  ///
  /// The `type` argument must be a subclass of [Element].
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// expect(find.byElementType(DomElement), findsOneComponent);
  /// ```
  Finder byElementType(Type type) => _ElementTypeFinder(type);

  /// Finds components whose current component is the instance given by the
  /// argument.
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// // Suppose you have a button created like this:
  /// Component myButton = Button(
  ///   child: Text('Update')
  /// );
  ///
  /// // You can find and tap on it like this:
  /// tester.tap(find.byComponent(myButton));
  /// ```
  Finder byComponent(Component component) => _ComponentFinder(component);

  /// Finds components using a component [predicate].
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// expect(find.byComponentPredicate(
  ///   (Component component) => component is DomComponent && component.classes.contains('alert'),
  ///   description: 'component with "alert" class',
  /// ), findsOneComponent);
  /// ```
  ///
  /// If [description] is provided, then this uses it as the description of the
  /// [Finder] and appears, for example, in the error message when the finder
  /// fails to locate the desired component. Otherwise, the description prints the
  /// signature of the predicate function.
  Finder byComponentPredicate(ComponentPredicate predicate, {String? description}) {
    return _ComponentPredicateFinder(predicate, description: description);
  }

  /// Finds components using an element [predicate].
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// expect(find.byElementPredicate(
  ///   // finds elements of type SingleChildElement, including
  ///   // those that are actually subclasses of that type.
  ///   // (contrast with byElementType, which only returns exact matches)
  ///   (Element element) => element is SingleChildElement,
  ///   description: '$SingleChildElement element',
  /// ), findsOneComponent);
  /// ```
  ///
  /// If [description] is provided, then this uses it as the description of the
  /// [Finder] and appears, for example, in the error message when the finder
  /// fails to locate the desired component. Otherwise, the description prints the
  /// signature of the predicate function.
  Finder byElementPredicate(ElementPredicate predicate, {String? description}) {
    return _ElementPredicateFinder(predicate, description: description);
  }

  /// Finds components that are descendants of the [of] parameter and that match
  /// the [matching] parameter.
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// expect(find.descendant(
  ///   of: find.componentWithText(Counter, 'label_1'), matching: find.text('value_1')
  /// ), findsOneComponent);
  /// ```
  ///
  /// If the [matchRoot] argument is true then the component(s) specified by [of]
  /// will be matched along with the descendants.
  Finder descendant({required Finder of, required Finder matching, bool matchRoot = false}) {
    return _DescendantFinder(of, matching, matchRoot: matchRoot);
  }

  /// Finds components that are ancestors of the [of] parameter and that match
  /// the [matching] parameter.
  ///
  /// ## Sample code
  ///
  /// ```dart
  /// // Test if a Text component that contains 'faded' is the
  /// // descendant of an Opacity component with opacity 0.5:
  /// expect(
  ///   tester.component<Opacity>(
  ///     find.ancestor(
  ///       of: find.text('faded'),
  ///       matching: find.byType('Opacity'),
  ///     )
  ///   ).opacity,
  ///   0.5
  /// );
  /// ```
  ///
  /// If the [matchRoot] argument is true then the component(s) specified by [of]
  /// will be matched along with the ancestors.
  Finder ancestor({
    required Finder of,
    required Finder matching,
    bool matchRoot = false,
  }) {
    return _AncestorFinder(of, matching, matchRoot: matchRoot);
  }
}

/// Searches a component tree and returns nodes that match a particular
/// pattern.
abstract class Finder {
  /// Describes what the finder is looking for. The description should be
  /// a brief English noun phrase describing the finder's pattern.
  String get description;

  /// Returns all the elements in the given list that match this
  /// finder's pattern.
  ///
  /// When implementing your own Finders that inherit directly from
  /// [Finder], this is the main method to override. If your finder
  /// can efficiently be described just in terms of a predicate
  /// function, consider extending [MatchFinder] instead.
  Iterable<Element> apply(Iterable<Element> candidates);

  /// Returns all the [Element]s that will be considered by this finder.
  ///
  /// See [collectAllElementsFrom].
  @protected
  Iterable<Element> get allCandidates {
    return collectAllElementsFrom(ComponentsBinding.instance!.rootElement!);
  }

  Iterable<Element>? _cachedResult;

  /// Returns the current result. If [precache] was called and returned true, this will
  /// cheaply return the result that was computed then. Otherwise, it creates a new
  /// iterable to compute the answer.
  ///
  /// Calling this clears the cache from [precache].
  Iterable<Element> evaluate() {
    final Iterable<Element> result = _cachedResult ?? apply(allCandidates);
    _cachedResult = null;
    return result;
  }

  /// Attempts to evaluate the finder. Returns whether any elements in the tree
  /// matched the finder. If any did, then the result is cached and can be obtained
  /// from [evaluate].
  ///
  /// If this returns true, you must call [evaluate] before you call [precache] again.
  bool precache() {
    assert(_cachedResult == null);
    final Iterable<Element> result = apply(allCandidates);
    if (result.isNotEmpty) {
      _cachedResult = result;
      return true;
    }
    _cachedResult = null;
    return false;
  }

  /// Returns a variant of this finder that only matches the first element
  /// matched by this finder.
  Finder get first => _FirstFinder(this);

  /// Returns a variant of this finder that only matches the last element
  /// matched by this finder.
  Finder get last => _LastFinder(this);

  /// Returns a variant of this finder that only matches the element at the
  /// given index matched by this finder.
  Finder at(int index) => _IndexFinder(this, index);

  @override
  String toString() {
    final List<Element> components = evaluate().toList();
    final int count = components.length;
    if (count == 0) return 'zero components with $description';
    if (count == 1) return 'exactly one component with $description: ${components.single}';
    if (count < 4) return '$count components with $description: $components';
    return '$count components with $description: ${components[0]}, ${components[1]}, ${components[2]}, ...';
  }
}

/// Applies additional filtering against a [parent] [Finder].
abstract class ChainedFinder extends Finder {
  /// Create a Finder chained against the candidates of another [Finder].
  ChainedFinder(this.parent);

  /// Another [Finder] that will run first.
  final Finder parent;

  /// Return another [Iterable] when given an [Iterable] of candidates from a
  /// parent [Finder].
  ///
  /// This is the method to implement when subclassing [ChainedFinder].
  Iterable<Element> filter(Iterable<Element> parentCandidates);

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    return filter(parent.apply(candidates));
  }

  @override
  Iterable<Element> get allCandidates => parent.allCandidates;
}

class _FirstFinder extends ChainedFinder {
  _FirstFinder(Finder parent) : super(parent);

  @override
  String get description => '${parent.description} (ignoring all but first)';

  @override
  Iterable<Element> filter(Iterable<Element> parentCandidates) sync* {
    yield parentCandidates.first;
  }
}

class _LastFinder extends ChainedFinder {
  _LastFinder(Finder parent) : super(parent);

  @override
  String get description => '${parent.description} (ignoring all but last)';

  @override
  Iterable<Element> filter(Iterable<Element> parentCandidates) sync* {
    yield parentCandidates.last;
  }
}

class _IndexFinder extends ChainedFinder {
  _IndexFinder(Finder parent, this.index) : super(parent);

  final int index;

  @override
  String get description => '${parent.description} (ignoring all but index $index)';

  @override
  Iterable<Element> filter(Iterable<Element> parentCandidates) sync* {
    yield parentCandidates.elementAt(index);
  }
}

/// Searches a component tree and returns nodes that match a particular
/// pattern.
abstract class MatchFinder extends Finder {
  /// Initializes a predicate-based Finder.
  MatchFinder() : super();

  /// Returns true if the given element matches the pattern.
  ///
  /// When implementing your own MatchFinder, this is the main method to override.
  bool matches(Element candidate);

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    return candidates.where(matches);
  }
}

class _TagFinder extends MatchFinder {
  _TagFinder(this.tag) : super();

  final String tag;

  @override
  String get description => 'tag "$tag"';

  @override
  bool matches(Element candidate) {
    final Component component = candidate.component;
    if (component is DomComponent) {
      return component.tag == tag;
    }
    return false;
  }
}

class _TextFinder extends MatchFinder {
  _TextFinder(this.text) : super();

  final String text;

  @override
  String get description => 'text "$text"';

  @override
  bool matches(Element candidate) {
    final Component component = candidate.component;
    if (component is Text) {
      return component.text == text;
    }
    return false;
  }
}

class _TextContainingFinder extends MatchFinder {
  _TextContainingFinder(this.pattern) : super();

  final Pattern pattern;

  @override
  String get description => 'text containing $pattern';

  @override
  bool matches(Element candidate) {
    final Component component = candidate.component;
    if (component is Text) {
      return component.text.contains(pattern);
    }
    return false;
  }
}

class _KeyFinder extends MatchFinder {
  _KeyFinder(this.key) : super();

  final Key key;

  @override
  String get description => 'key $key';

  @override
  bool matches(Element candidate) {
    return candidate.component.key == key;
  }
}

class _ComponentTypeFinder extends MatchFinder {
  _ComponentTypeFinder(this.componentType) : super();

  final Type componentType;

  @override
  String get description => 'type "$componentType"';

  @override
  bool matches(Element candidate) {
    return candidate.component.runtimeType == componentType;
  }
}

class _ElementTypeFinder extends MatchFinder {
  _ElementTypeFinder(this.elementType) : super();

  final Type elementType;

  @override
  String get description => 'type "$elementType"';

  @override
  bool matches(Element candidate) {
    return candidate.runtimeType == elementType;
  }
}

class _ComponentFinder extends MatchFinder {
  _ComponentFinder(this.component) : super();

  final Component component;

  @override
  String get description => 'the given component ($component)';

  @override
  bool matches(Element candidate) {
    return candidate.component == component;
  }
}

class _ComponentPredicateFinder extends MatchFinder {
  _ComponentPredicateFinder(this.predicate, {String? description})
      : _description = description,
        super();

  final ComponentPredicate predicate;
  final String? _description;

  @override
  String get description => _description ?? 'component matching predicate ($predicate)';

  @override
  bool matches(Element candidate) {
    return predicate(candidate.component);
  }
}

class _ElementPredicateFinder extends MatchFinder {
  _ElementPredicateFinder(this.predicate, {String? description})
      : _description = description,
        super();

  final ElementPredicate predicate;
  final String? _description;

  @override
  String get description => _description ?? 'element matching predicate ($predicate)';

  @override
  bool matches(Element candidate) {
    return predicate(candidate);
  }
}

class _DescendantFinder extends Finder {
  _DescendantFinder(
    this.ancestor,
    this.descendant, {
    this.matchRoot = false,
  }) : super();

  final Finder ancestor;
  final Finder descendant;
  final bool matchRoot;

  @override
  String get description {
    if (matchRoot) return '${descendant.description} in the subtree(s) beginning with ${ancestor.description}';
    return '${descendant.description} that has ancestor(s) with ${ancestor.description}';
  }

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    return candidates.where((Element element) => descendant.evaluate().contains(element));
  }

  @override
  Iterable<Element> get allCandidates {
    final Iterable<Element> ancestorElements = ancestor.evaluate();
    final List<Element> candidates =
        ancestorElements.expand<Element>((Element element) => collectAllElementsFrom(element)).toSet().toList();
    if (matchRoot) candidates.insertAll(0, ancestorElements);
    return candidates;
  }
}

class _AncestorFinder extends Finder {
  _AncestorFinder(this.descendant, this.ancestor, {this.matchRoot = false}) : super();

  final Finder ancestor;
  final Finder descendant;
  final bool matchRoot;

  @override
  String get description {
    if (matchRoot) return 'ancestor ${ancestor.description} beginning with ${descendant.description}';
    return '${ancestor.description} which is an ancestor of ${descendant.description}';
  }

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    return candidates.where((Element element) => ancestor.evaluate().contains(element));
  }

  @override
  Iterable<Element> get allCandidates {
    final List<Element> candidates = <Element>[];
    for (final Element root in descendant.evaluate()) {
      final List<Element> ancestors = <Element>[];
      if (matchRoot) ancestors.add(root);
      root.visitAncestorElements((Element element) {
        ancestors.add(element);
        return true;
      });
      candidates.addAll(ancestors);
    }
    return candidates;
  }
}
