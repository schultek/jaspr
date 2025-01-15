import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';

class Icon extends StatelessComponent {
  const Icon(this.name, {this.size, super.key});

  final String name;
  final Unit? size;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (name == 'jaspr') {
      yield img(src: 'images/logo_icon.svg', styles: Styles.box(height: size ?? 1.2.em));
      return;
    }
    yield i(classes: 'icon-$name', styles: Styles.text(fontSize: size ?? 1.2.em), []);
  }

  @css
  static final List<StyleRule> styles = [
    css('[class^=icon-custom-]').box(width: 1.em, height: 1.em).raw({
      '-webkit-mask': 'var(--icon) no-repeat',
      'mask': 'var(--icon) no-repeat',
      '-webkit-mask-size': '100% 100%',
      'mask-size': '100% 100%',
      'background-color': 'currentColor',
      'color': 'inherit',
    }),
    css('.icon-custom-discord').raw({'--icon': 'url("$discordIcon")'}),
    css('.icon-custom-github').raw({'--icon': 'url("$githubIcon")'}),
  ];
}
