import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart';

import '../../../../components/icon.dart';
import '../../../../constants/theme.dart';

@client
class InstallCommand extends StatefulComponent {
  const InstallCommand({super.key});

  @override
  State createState() => InstallCommandState();
}

class InstallCommandState extends State<InstallCommand> {
  bool copied = false;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'install-jaspr',
      events: events(
        onClick: () {
          window.navigator.clipboard.writeText('dart pub global activate jaspr_cli');
          setState(() {
            copied = true;
          });
          Timer(const Duration(seconds: 2), () {
            setState(() {
              copied = false;
            });
          });
        },
      ),
      [
        span([
          Icon('terminal'),
          code([.text('dart pub global activate jaspr_cli')]),
          button(
            styles: copied ? Styles(color: Colors.forestGreen) : null,
            attributes: {'aria-label': 'Copy'},
            [Icon(copied ? 'check' : 'copy')],
          ),
        ]),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.install-jaspr', [
      css('&').styles(
        padding: .symmetric(horizontal: .8.rem, vertical: .6.rem),
        margin: .only(bottom: .8.rem),
        border: .all(color: borderColor2),
        radius: .circular(3.em),
        cursor: .copy,
        color: textDark,
        fontSize: .8.rem,
        backgroundColor: surfaceLow,
      ),
      css('& span').styles(
        display: .flex,
        alignItems: .center,
        gap: .column(0.6.rem),
      ),
      css('& button', [
        css('&').styles(
          display: .inlineFlex,
          padding: .zero,
          border: .unset,
          cursor: .pointer,
          alignItems: .center,
          color: .unset,
          backgroundColor: Colors.transparent,
        ),
        css('&:hover').styles(color: textBlack),
      ]),
    ]),
  ];
}
