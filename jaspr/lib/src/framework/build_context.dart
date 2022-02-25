part of framework;

/// The BuildContext supplied to a Components build() method,
/// as known from Flutter
abstract class BuildContext {
  InheritedComponent dependOnInheritedElement(InheritedElement ancestor, {Object? aspect});

  T? dependOnInheritedComponentOfExactType<T extends InheritedComponent>({Object? aspect});

  InheritedElement? getElementForInheritedComponentOfExactType<T extends InheritedComponent>();

  T? getInheritedComponentOfExactType<T extends InheritedComponent>();

  T? findAncestorStateOfType<T extends State>();

  void visitAncestorElements(bool Function(Element element) visitor);
}
