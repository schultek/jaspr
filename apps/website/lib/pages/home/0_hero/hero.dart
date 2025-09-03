import 'package:jaspr/jaspr.dart';

import '../../../components/gradient_border.dart';
import '../../../components/icon.dart';
import '../../../components/link_button.dart';
import '../../../constants/theme.dart';
import 'components/install_command.dart';
import 'components/meet_jaspr_button.dart';

class Hero extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return section(id: "hero", [
      div([
        a(
            classes: 'hero-pill',
            href: "https://marketplace.visualstudio.com/items?itemName=schultek.jaspr-code",
            target: Target.blank,
            [
              GradientBorder(
                radius: 17,
                fixed: true,
                child: div(classes: 'pill-content', [
                  text("The official Jaspr VSCode Extension is out"),
                  Icon('arrow-right'),
                ]),
              ),
            ]),
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
                label: 'Get Started', icon: 'arrow-right', to: 'https://docs.jaspr.site/get_started/quick_start'),
            MeetJasprButton(),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
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
          css('.hero-pill', [
            css('&').styles(
              margin: Margin.only(bottom: 1.rem),
              radius: BorderRadius.circular(20.px),
              raw: {
                'background': 'linear-gradient(175deg, ${primaryMid.value}33 0%, ${primaryMid.value}11 80%)',
              },
            ),
            css('.pill-content').styles(
              display: Display.flex,
              padding: Padding.symmetric(vertical: 0.5.rem, horizontal: 0.8.rem),
              gap: Gap(column: 0.5.rem),
              color: textBlack,
              fontSize: 0.8.rem,
              fontWeight: FontWeight.w700,
            ),
          ]),
          css('& > div').styles(
            display: Display.flex,
            maxWidth: 45.rem,
            flexDirection: FlexDirection.column,
            justifyContent: JustifyContent.center,
            alignItems: AlignItems.center,
          ),
          css('p').combine(bodyMedium),
          css('.cta').styles(
            display: Display.flex,
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
