import 'package:jaspr/jaspr.dart';
import 'package:test/test.dart';

import 'finders.dart';

/// Asserts that the [Finder] matches no components in the component tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsNothing);
/// ```
///
/// See also:
///
///  * [findsComponents], when you want the finder to find one or more components.
///  * [findsOneComponent], when you want the finder to find exactly one component.
///  * [findsNComponents], when you want the finder to find a specific number of components.
const Matcher findsNothing = _FindsComponentMatcher(null, 0);

/// Asserts that the [Finder] locates at least one component in the component tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsComponents);
/// ```
///
/// See also:
///
///  * [findsNothing], when you want the finder to not find anything.
///  * [findsOneComponent], when you want the finder to find exactly one component.
///  * [findsNComponents], when you want the finder to find a specific number of components.
const Matcher findsComponents = _FindsComponentMatcher(1, null);

/// Asserts that the [Finder] locates at exactly one component in the component tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsOneComponent);
/// ```
///
/// See also:
///
///  * [findsNothing], when you want the finder to not find anything.
///  * [findsComponents], when you want the finder to find one or more components.
///  * [findsNComponents], when you want the finder to find a specific number of components.
const Matcher findsOneComponent = _FindsComponentMatcher(1, 1);

/// Asserts that the [Finder] locates the specified number of components in the component tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsNComponents(2));
/// ```
///
/// See also:
///
///  * [findsNothing], when you want the finder to not find anything.
///  * [findsComponents], when you want the finder to find one or more components.
///  * [findsOneComponent], when you want the finder to find exactly one component.
Matcher findsNComponents(int n) => _FindsComponentMatcher(n, n);

/// A matcher for functions that throw [AssertionError].
///
/// This is equivalent to `throwsA(isA<AssertionError>())`.
///
/// If you are trying to test whether a call to [ComponentTester.pumpComponent]
/// results in an [AssertionError], see
/// [TestComponentsFlutterBinding.takeException].
///
/// See also:
///
///  * [throwsFlutterError], to test if a function throws a [FlutterError].
///  * [throwsArgumentError], to test if a functions throws an [ArgumentError].
///  * [isAssertionError], to test if any object is any kind of [AssertionError].
final Matcher throwsAssertionError = throwsA(isAssertionError);

/// A matcher for [AssertionError].
///
/// This is equivalent to `isInstanceOf<AssertionError>()`.
///
/// See also:
///
///  * [throwsAssertionError], to test if a function throws any [AssertionError].
///  * [isFlutterError], to test if any object is a [FlutterError].
final TypeMatcher<AssertionError> isAssertionError = isA<AssertionError>();

class _FindsComponentMatcher extends Matcher {
  const _FindsComponentMatcher(this.min, this.max);

  final int? min;
  final int? max;

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) {
    assert(min != null || max != null);
    assert(min == null || max == null || min! <= max!);
    matchState[Finder] = finder;
    int count = 0;
    final Iterator<Element> iterator = finder.evaluate().iterator;
    if (min != null) {
      while (count < min! && iterator.moveNext()) {
        count += 1;
      }
      if (count < min!) {
        return false;
      }
    }
    if (max != null) {
      while (count <= max! && iterator.moveNext()) {
        count += 1;
      }
      if (count > max!) {
        return false;
      }
    }
    return true;
  }

  @override
  Description describe(Description description) {
    assert(min != null || max != null);
    if (min == max) {
      if (min == 1) {
        return description.add('exactly one matching node in the component tree');
      }
      return description.add('exactly $min matching nodes in the component tree');
    }
    if (min == null) {
      if (max == 0) {
        return description.add('no matching nodes in the component tree');
      }
      if (max == 1) {
        return description.add('at most one matching node in the component tree');
      }
      return description.add('at most $max matching nodes in the component tree');
    }
    if (max == null) {
      if (min == 1) {
        return description.add('at least one matching node in the component tree');
      }
      return description.add('at least $min matching nodes in the component tree');
    }
    return description.add('between $min and $max matching nodes in the component tree (inclusive)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    final Finder finder = matchState[Finder] as Finder;
    final int count = finder.evaluate().length;
    if (count == 0) {
      assert(min != null && min! > 0);
      if (min == 1 && max == 1) {
        return mismatchDescription.add('means none were found but one was expected');
      }
      return mismatchDescription.add('means none were found but some were expected');
    }
    if (max == 0) {
      if (count == 1) {
        return mismatchDescription.add('means one was found but none were expected');
      }
      return mismatchDescription.add('means some were found but none were expected');
    }
    if (min != null && count < min!) {
      return mismatchDescription.add('is not enough');
    }
    assert(max != null && count > min!);
    return mismatchDescription.add('is too many');
  }
}
