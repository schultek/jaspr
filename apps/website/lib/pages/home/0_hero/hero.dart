import 'package:jaspr/jaspr.dart';

import 'components/install_command.dart';
import '../../../components/link_button.dart';
import 'components/meet_jaspr_button.dart';
import '../../../constants/theme.dart';

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
          text('Jaspr is a free and open source framework for building websites in Dart.'),
          br(),
          text('Create fast and dynamic web experiences with ease in a familiar language and ecosystem.'),
        ]),
        div(classes: 'cta', [
          InstallCommand(),
          div(classes: 'actions', [
            LinkButton.filled(
                label: 'Get Started',
                icon: 'arrow-right',
                to: 'https://docs.page/schultek/jaspr/get_started/installation'),
            MeetJasprButton(),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#hero', [
      css('&')
          .box(
            minHeight: 100.vh,
            padding: EdgeInsets.only(left: contentPadding, right: contentPadding, top: 8.rem, bottom: 4.rem),
            boxSizing: BoxSizing.borderBox,
          )
          .flexbox(justifyContent: JustifyContent.center, alignItems: AlignItems.center)
          .text(align: TextAlign.center),
      css('& > div').box(maxWidth: 45.rem).flexbox(
            direction: FlexDirection.column,
            justifyContent: JustifyContent.center,
            alignItems: AlignItems.center,
          ),
      css('p').combine(bodyMedium),
      css('.cta')
          .box(margin: EdgeInsets.only(top: 2.rem))
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.center),
    ]),
    css.media(MediaQuery.all(maxWidth: mobileBreakpoint), [
      css('#hero').box(minHeight: 95.vh),
    ])
  ];
}
