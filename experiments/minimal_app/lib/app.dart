import 'package:jaspr/jaspr.dart';
import 'package:jaspr/styles.dart';

import 'theme.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield StaticTheme(
      theme: ButtonTheme(),
      child: Builder(builder: (context) sync* {
        yield ThemedComponent(
          tag: 'button',
          theme: Theme.of<ButtonTheme>(context).resolve(isOutlined: true),
          child: Text('Hello World'),
        );
      }),
    );
  }
}

class ButtonTheme extends ThemeData {
  const ButtonTheme() : super('button');

  Styles get styles => const Styles.background(
        color: Color.named('blue'),
      );

  List<ThemeData> get variants => [
        const ThemeData.variant(
          'is-outlined',
          Styles.background(
            color: Colors.lightBlue,
          ),
        ),
      ];

  @override
  ResolvedThemeData resolve({bool isOutlined = false}) {
    return applyVariants([
      if (isOutlined) 'is-outlined',
    ]);
  }
}
