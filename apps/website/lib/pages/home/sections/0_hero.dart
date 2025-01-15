// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';

import '../../../components/install_command.dart';
import '../../../components/link_button.dart';

class Hero extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section(id: "hero", [
      div([
        h1([
          text('The '),
          span(classes: 'text-gradient', [text('Web Framework')]),
          text(' for Dart Developers')
        ]),
        p([
          text('Jaspr is an open source framework for building websites in Dart.'),
        ]),
        div(classes: 'cta', [
          InstallCommand(),
          div(classes: 'row', [
            LinkButton.filled(label: 'Get Started', icon: 'arrow-right', to: 'https://docs.page/schultek/jaspr/get_started/installation'),
            LinkButton.outlined(label: 'Meet Jaspr', icon: 'jaspr', to: '#meet'),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#hero', [
      css('&')
          .box(minHeight: 100.vh)
          .flexbox(justifyContent: JustifyContent.center, alignItems: AlignItems.center)
          .text(align: TextAlign.center),
      css('& > div').box(maxWidth: 45.rem).flexbox(
            direction: FlexDirection.column,
            justifyContent: JustifyContent.center,
            alignItems: AlignItems.center,
          ),
      css('h1')
          .box(margin: EdgeInsets.only(top: Unit.zero, bottom: 0.1.rem))
          .text(fontSize: 4.rem, fontWeight: FontWeight.w800),
      css('.cta')
          .box(margin: EdgeInsets.only(top: 2.rem))
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.center),
    ]),
  ];
}
