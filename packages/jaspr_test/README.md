# jaspr_test

Testing utilities for the [jaspr framework](https://pub.dev/packages/jaspr).

It is built as a layer on top of `package:test` and has a similar api to `flutter_test`.

## Setup

To get started, add the package as a dev dependency to your project:
```shell
dart pub add jaspr_test --dev
```

A simple component test looks like this:

```dart
// This also exports 'package:test' so no need for an additional import.
import 'package:jaspr_test/jaspr_test.dart';

// Import the components that you want to test.
import 'my_component.dart';

void main() {
  group('simple component test', () {
    
    // Creates a new ComponentTester for each test.
    late ComponentTester tester;
    setUp(() {
      tester = ComponentTester.setUp();
    });

    test('renders my component', () async {
      // We want to test the MyComponent component.
      // Assume this shows a count and a button to increase it.
      await tester.pumpComponent(MyComponent());

      // Should render a [Text] component with content 'Count: 0'.
      expect(find.text('Count: 0'), findsOneComponent);

      // Searches for the <button> element and simulates a click event.
      await tester.click(find.tag('button'));

      // Should render a [Text] component with content 'Count: 1'.
      expect(find.text('Count: 1'), findsOneComponent);
    });
  });
}
```

## Testers

Since jaspr is a fullstack-framework, there are **3** tester classes to choose from:

- **ComponentTester** can unit-test components in a simulated testing environment.

  Use as shown above, by initializing with `ComponentTester.setUp()` and providing a component
  using `tester.pumpComponent()`.

  See [here](https://pub.dev/documentation/jaspr_test/latest/server_test/ComponentTester-class.html) for a full api reference.

- **BrowserTester** can test components and dom-interactions in a headless browser environment.

  Use similar to the `ComponentTester` with additional options for the `url` and `initialStateData` to
  simulate synced state from the server.

  See [here](https://pub.dev/documentation/jaspr_test/latest/browser_test/BrowserTester-class.html) for a full api reference.

- **ServerTester** can test the rendering of components in a simulated server environment.

  This spins up a virtual http server where you can send requests and test the server-rendered response
  for your components.

  See [here](https://pub.dev/documentation/jaspr_test/latest/server_test/ServerTester-class.html) for a full api reference.


For more examples on how to use the testing package, check out the [tests in the jaspr package](https://github.com/schultek/jaspr/tree/main/packages/jaspr/test).
