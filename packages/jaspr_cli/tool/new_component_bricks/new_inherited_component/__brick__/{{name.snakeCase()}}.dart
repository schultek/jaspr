import 'package:jaspr/jaspr.dart';

class {{name.pascalCase()}} extends InheritedComponent {
  const {{name.pascalCase()}}({required this.data, required super.child, super.key});

  // This is the data that will be passed down the Component tree.
  // TODO: change to your data
  final String data;

  /// Obtains and returns the nearest InheritedComponent of type [{{name.pascalCase()}}] in the tree, null if there is none.
  static {{name.pascalCase()}}? maybeOf(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<{{name.pascalCase()}}>();
  }

  /// Obtains and returns the nearest [{{name.pascalCase()}}] in the tree.
  /// Throws if there is none, use [maybeOf] if you wish to handle the missing case yourself.
  static {{name.pascalCase()}} of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No {{name.pascalCase()}} found in context');
    return result!;
  }

  @override
  bool updateShouldNotify({{name.pascalCase()}} oldComponent) {
    // TODO: depending on your data, you may want to update this method
    return data != oldComponent.data;
  }
}
