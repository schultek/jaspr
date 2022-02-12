part of framework;

/// As known from Flutter
abstract class BuildContext {
  InheritedComponent dependOnInheritedElement(InheritedElement ancestor, {Object? aspect});

  T? dependOnInheritedComponentOfExactType<T extends InheritedComponent>({Object? aspect});

  InheritedElement? getElementForInheritedComponentOfExactType<T extends InheritedComponent>();

  T? getInheritedComponentOfExactType<T extends InheritedComponent>();

  T? findAncestorStateOfType<T extends State>();
}
