import 'package:jaspr/jaspr.dart';
import 'package:jaspr/styles.dart';

import 'theme.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield StaticTheme(
      theme: const ButtonTheme(Colors.red),
      child: Builder(builder: (context) sync* {
        yield DomComponent(
          tag: 'button',
          classes: ButtonTheme.of(context).resolve(),
          child: Text('Standard'),
        );

        yield DomComponent(
          tag: 'button',
          classes: ButtonTheme.of(context).resolve(isOutlined: true),
          child: Text('Outlined'),
        );
      }),
    );
  }
}

class ButtonTheme extends ThemeData {
  const ButtonTheme(this.primary) : super('button');

  final Color primary;

  static ButtonTheme of(BuildContext context) => Theme.of(context);

  Styles buildStyles() {
    return Styles.combine([
      Styles.box(
        border: Border.all(BorderSide(style: BorderStyle.none)),
      ),
      Styles.background(color: primary),
    ]);
  }

  List<ThemeData> buildVariants() {
    return [
      ThemeData.variant(
        'is-outlined',
        Styles.combine([
          Styles.box(
            border: Border.all(BorderSide(
              color: primary,
              width: Unit.pixels(2),
              style: BorderStyle.solid,
            )),
          ),
          Styles.background(color: Colors.white),
        ]),
      ),
    ];
  }

  @override
  List<String> resolve({bool isOutlined = false}) {
    return [
      name,
      if (isOutlined) 'is-outlined',
    ];
  }
}
