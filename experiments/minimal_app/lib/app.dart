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
          classes: context.theme.button.resolve(),
          child: Text('Standard'),
        );

        yield DomComponent(
          tag: 'button',
          classes: context.theme.button.resolve(isOutlined: true),
          child: Text('Outlined'),
        );
      }),
    );
  }
}

extension ContextTheme on BuildContext {
  AppTheme get theme => AppTheme._(this);
}

class AppTheme {
  final BuildContext _context;
  AppTheme._(this._context);

  T get<T extends ThemeData>() => Theme.of(_context);
}

extension on AppTheme {
  ButtonTheme get button => get<ButtonTheme>();
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
