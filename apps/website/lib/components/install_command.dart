import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart';

import 'icon.dart';

@client
class InstallCommand extends StatefulComponent {
  const InstallCommand({super.key});

  @override
  State createState() => InstallCommandState();
}

class InstallCommandState extends State<InstallCommand> {
  bool copied = false;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'install-jaspr', events: events(onClick: () {
      window.navigator.clipboard.writeText('dart pub global activate jaspr');
      setState(() {
        copied = true;
      });
      Timer(const Duration(seconds: 2), () {
        setState(() {
          copied = false;
        });
      });
    }), [
      span([
        Icon('terminal'),
        code([text('dart pub global activate jaspr_cli')]),
        button(styles: copied ? Styles.text(color: Colors.forestGreen) : null, [
          Icon(copied ? 'check' : 'copy'),
        ]),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.install-jaspr', [
      css('&')
          .box(
            margin: EdgeInsets.only(bottom: .8.rem),
            border: Border.all(BorderSide.solid(color: Colors.gainsboro)),
            radius: BorderRadius.circular(3.em),
            padding: EdgeInsets.symmetric(horizontal: .8.rem, vertical: .6.rem),
            cursor: Cursor.copy,
          )
          .background(color: Colors.whiteSmoke)
          .text(color: Color.hex('#555'), fontSize: .8.rem),
      css('& span').flexbox(alignItems: AlignItems.center, gap: Gap(column: .6.rem)),
      css('& button', [
        css('&')
            .flexbox(alignItems: AlignItems.center)
            .box(display: Display.inlineFlex, border: Border.unset, cursor: Cursor.pointer, padding: EdgeInsets.zero)
            .background(color: Colors.transparent)
            .text(color: Color.unset),
        css('&:hover').text(color: Colors.black),
      ]),
    ]),
  ];
}
