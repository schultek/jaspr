import 'package:jaspr/jaspr.dart';

import '../page.dart';

/// A secondary output for a page.
///
/// See also:
/// - [SecondaryMarkdownOutput] for a secondary output containing the unparsed markdown of a page.
abstract class SecondaryOutput {
  /// A pattern to match the pages path that this output should be created for.
  Pattern get pattern;

  /// Creates the route for this output based on the given base route.
  String createRoute(String route);

  /// Builds the secondary output component for a page.
  ///
  /// This is called after the template rendering, but before the page parsing.
  Component build(Page page);
}

class InheritedSecondaryOutput extends InheritedComponent {
  const InheritedSecondaryOutput({required this.builder, super.child});

  final Component Function(Page) builder;

  static InheritedSecondaryOutput? of(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<InheritedSecondaryOutput>();
  }

  @override
  bool updateShouldNotify(covariant InheritedSecondaryOutput oldComponent) {
    return oldComponent.builder != builder;
  }
}
