import 'package:jaspr/dom.dart';

import '../../../components/link_button.dart';
import '../../../constants/theme.dart';
import 'components/sponsors_list.dart';

class Community extends StatelessComponent {
  const Community({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'community', [
      span(classes: 'caption text-gradient', [.text('Community')]),
      h2([.text('Join the Community')]),
      div(classes: 'community-card', [
        div(classes: 'sponsor', [
          h4([.text('Sponsor Jaspr')]),
          p([
            .text(
              'Jaspr is free and open source. Sponsorships allow me to spend more time developing the framework and keep the project sustainable in the years to come. I\'m super thankful for all support.',
            ),
          ]),
          h5([.text('Current Sponsors')]),
          SponsorsList(),
          div(classes: 'actions', [
            LinkButton.filled(
              icon: 'hand-heart',
              label: 'Become a Sponsor',
              to: 'https://github.com/sponsors/schultek',
            ),
          ]),
          p([
            em([
              .text(
                'Are you interested in a larger sponsoring including a prominent logo placement on this website? Contact me at ',
              ),
              a(href: 'mailto:kilian@schultek.dev', classes: 'animated-underline', [
                .text('kilian@schultek.dev'),
              ]),
              .text('.'),
            ]),
          ]),
        ]),
        div([
          h4([.text('Discord')]),
          p([
            .text(
              'Join our Discord community with over 500 developers. Chat with other developers, ask questions, and share your projects.',
            ),
          ]),
          div(classes: 'actions', [
            LinkButton.outlined(icon: 'custom-discord', label: 'Join Discord', to: 'https://discord.gg/XGXrGEk4c6'),
          ]),
          h4([.text('Enterprise Support')]),
          p([
            .text(
              'Are you a startup or enterprise looking for paid support, consulting, or custom development? Don\'t hesitate to contact me.',
            ),
          ]),
          div(classes: 'actions', [
            LinkButton.outlined(icon: 'send', label: 'Get Support', to: 'mailto:kilian@schultek.dev'),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('#community', [
      css('&').styles(
        display: .flex,
        padding: .only(top: sectionPadding, left: contentPadding, right: contentPadding, bottom: sectionPadding),
        flexDirection: .column,
        alignItems: .center,
        textAlign: .center,
      ),
      css('.community-card', [
        css('&').styles(
          display: .flex,
          maxWidth: maxContentWidth,
          margin: .only(top: 3.rem),
          border: .all(color: borderColor, width: 2.px),
          radius: .circular(12.px),
          shadow: .new(offsetX: 4.px, offsetY: 4.px, blur: 20.px, color: shadowColor1),
          flexDirection: .row,
          flexWrap: .wrap,
          textAlign: .start,
          raw: {'background': 'linear-gradient(180deg, ${background.value} 0%, ${surface.value} 100%)'},
        ),
        css('& > div').styles(
          padding: .all(2.rem),
          flex: .new(grow: 1, basis: 20.rem),
        ),
        css('& > div > h4:not(:first-child)').styles(margin: .only(top: 3.rem)),
        css('.sponsor', [
          css('&').styles(
            border: .only(
              right: .new(color: borderColor, width: 2.px),
            ),
          ),
          css('h5').styles(margin: .only(bottom: 0.5.rem)),
          css('.actions').styles(margin: .only(top: 2.rem)),
          css('p:last-child').styles(margin: .only(top: 2.rem)).combine(bodySmall),
        ]),
      ]),
    ]),
  ];
}
