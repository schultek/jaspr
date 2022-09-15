import 'package:jaspr/jaspr.dart';

import 'theme.dart';

@app
class App extends StatelessComponent {
  final int numCounters;

  const App(this.numCounters);

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

    yield Padding(
      padding: const EdgeInsets.all(Unit.pixels(5)),

    );
  }
}

class Padding extends StatelessComponent {
  const Padding({required this.padding, Key? key}) : super(key: key);

  final EdgeInsets padding;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ;
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

@theme
class ButtonTheme extends _$ButtonTheme {
  const ButtonTheme(this.primary);

  final Color primary;

  Styles get styles {
    return Styles.combine([
      Styles.box(
        border: Border.all(BorderSide(style: BorderStyle.none)),
      ),
      Styles.background(color: primary),
    ]);
  }

  @variant
  Styles get isOutlined => Styles.combine([
    Styles.box(
      border: Border.all(BorderSide(
        color: primary,
        width: Unit.pixels(2),
        style: BorderStyle.solid,
      )),
    ),
    Styles.background(color: Colors.white),
  ]);
}

const theme = 0;
const variant = 1;

abstract class _$ButtonTheme extends ThemeData {

  const _$ButtonTheme() : super('button');

  Styles get styles;

  @override
  List<Styles> build() => styles;

  @override
  List<ThemeData> buildVariants() {
    return [is]
  }

  @override
  List<String> resolve({bool isOutlined = false}) {
    return [
      name,
      if (isOutlined) 'is-outlined',
    ];
  }
}