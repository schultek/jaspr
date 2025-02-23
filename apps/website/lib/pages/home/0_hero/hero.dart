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
                label: 'Get Started', icon: 'arrow-right', to: 'https://docs.jaspr.site/get_started/installation'),
            MeetJasprButton(),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#hero', [
      css('&').styles(
        display: Display.flex,
        minHeight: 100.vh,
        padding: Padding.only(left: contentPadding, right: contentPadding, top: 8.rem, bottom: 4.rem),
        boxSizing: BoxSizing.borderBox,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
        textAlign: TextAlign.center,
      ),
      css('& > div').styles(
        display: Display.flex,
        maxWidth: 45.rem,
        flexDirection: FlexDirection.column,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
      ),
      css('p').combine(bodyMedium),
      css('.cta').styles(
        margin: Margin.only(top: 2.rem),
        flexDirection: FlexDirection.column,
        alignItems: AlignItems.center,
      ),
    ]),
    css.media(MediaQuery.all(maxWidth: mobileBreakpoint), [
      css('#hero').styles(minHeight: 95.vh),
    ])
  ];
}
