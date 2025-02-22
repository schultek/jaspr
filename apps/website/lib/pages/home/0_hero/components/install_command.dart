import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart';
import 'package:website/constants/theme.dart';

import '../../../../components/icon.dart';

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
        button(styles: copied ? Styles(color: Colors.forestGreen) : null, attributes: {
          'aria-label': 'Copy'
        }, [
          Icon(copied ? 'check' : 'copy'),
        ]),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.install-jaspr', [
      css('&').styles(
        border: Border(color: borderColor2),
        margin: Margin.only(bottom: .8.rem),
        radius: BorderRadius.circular(3.em),
        padding: Padding.symmetric(horizontal: .8.rem, vertical: .6.rem),
        cursor: Cursor.copy,
        backgroundColor: surfaceLow,
        color: textDark,
        fontSize: .8.rem,
      ),
      css('& span').styles(
        display: Display.flex,
        alignItems: AlignItems.center,
        gap: Gap(column: .6.rem),
      ),
      css('& button', [
        css('&').styles(
          alignItems: AlignItems.center,
          display: Display.inlineFlex,
          border: Border.unset,
          cursor: Cursor.pointer,
          padding: Padding.zero,
          backgroundColor: Colors.transparent,
          color: Color.unset,
        ),
        css('&:hover').styles(color: textBlack),
      ]),
    ]),
  ];
}
