import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../../../components/code_window/code_window.dart';
import '../../../components/link_button.dart';
import '../../../constants/theme.dart';
import 'components/modes_animation.dart';

class Meet extends StatelessComponent {
  const Meet({super.key});

  @override
  Component build(BuildContext context) {
    final versions = context.page.data.site['versions'] as Map<String, Object?>? ?? {};

    return section(id: 'meet', [
      div(classes: 'meet-section meet-components', [
        div([
          h3(classes: 'select-target-1', [.text('Everything is a Component')]),
          p(classes: 'select-target-2', [
            .text(
              'Jaspr Components are the fundamental building blocks of any Jaspr website and look very similar '
              'to Flutter widgets. However, Jaspr renders actual HTML and CSS from your components, resulting in '
              'great SEO and fast loading times.',
            ),
          ]),
          div(classes: 'actions select-target-3', [
            div(classes: 'select-target-4', [
              LinkButton.filled(
                label: 'Try out in Playground',
                icon: 'rocket',
                to: 'https://playground.jaspr.site?sample=counter',
              ),
            ]),
            div(classes: 'select-target-5', [
              LinkButton.outlined(
                label: 'Read the Docs',
                icon: 'book-text',
                to: 'https://docs.jaspr.site/concepts/components',
              ),
            ]),
          ]),
        ]),
        div([
          CodeWindow(
            name: 'app.dart',
            inactiveName: 'button.dart',
            selectable: true,
            source: '''
          import 'package:jaspr/jaspr.dart';
          import 'button.dart';
          
          class App extends StatelessComponent {
            const App({super.key});

            @override
            Component build(BuildContext context) {
              return div([
                // Hover me!
                h2([.text('Everything is a Component')]),
                p([.text('Jaspr Components are the fundamental building blocks ...')]),
                div(classes: 'actions', [
                  Button(
                    primary: true,
                    label: 'Try out in Playground', 
                    icon: 'rocket',
                  ),
                  Button(
                    label: 'Read the Docs', 
                    icon: 'book-text',
                  ),
                ]),
              ]);
            }
          }
          ''',
            lineClasses: {
              10: 'select-trigger-1',
              11: 'select-trigger-2',
              12: 'select-trigger-3',
              13: 'select-trigger-4',
              14: 'select-trigger-4',
              15: 'select-trigger-4',
              16: 'select-trigger-4',
              17: 'select-trigger-4',
              18: 'select-trigger-5',
              19: 'select-trigger-5',
              20: 'select-trigger-5',
              21: 'select-trigger-5',
              22: 'select-trigger-3',
            },
          ),
        ]),
      ]),
      div(classes: 'meet-section meet-modes', [
        div([
          CodeWindow(
            name: 'pubspec.yaml',
            inactiveName: 'main.dart',
            source:
                '''
          name: my_awesome_website
          description: A new Jaspr site.

          environment:  
            sdk: ^3.10.0

          dependencies:  
            jaspr: ^${versions['latestCore']}
            jaspr_content: ^${versions['latestContent']}
            jaspr_router: ^${versions['latestRouter']}
            
          dev_dependencies:
            jaspr_builder: ^${versions['latestCore']}
            jaspr_lints: ^${versions['latestLints']}

          jaspr:
            mode: static
          ''',
            language: 'yaml',
            lineClasses: {15: 'put-top', 16: 'put-top jaspr-mode'},
          ),
          div(classes: 'mode-highlight', []),
        ]),
        div([
          h3([.text('Build '), br(), ModesAnimation(), br(), .text(' using pure Dart')]),
          p([
            .text(
              'Choose the rendering strategy you need. Generate static html at build time, '
              'pre-render pages dynamically on the server or build a single page application. Jaspr has you covered.',
            ),
          ]),
          div(classes: 'actions', [
            LinkButton.filled(
              label: 'Explore Modes',
              icon: 'book-open',
              to: 'https://docs.jaspr.site/dev/modes',
            ),
            LinkButton.outlined(
              label: 'See what others have built',
              icon: 'newspaper',
              to: 'https://discord.gg/Ej3Fkt5SGx',
            ),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('#meet', [
      css('&').styles(
        display: .flex,
        minHeight: 100.vh,
        padding: .only(top: 2.rem, left: contentPadding, right: contentPadding),
        flexDirection: .column,
        alignItems: .center,
        gap: .row(sectionPadding),
      ),
      css('.meet-section', [
        css('&').styles(
          display: .flex,
          maxWidth: maxContentWidth,
          flexDirection: .row,
          flexWrap: .wrap,
          alignItems: .center,
          gap: .new(row: 4.rem, column: 4.rem),
        ),
        css('& > *').styles(
          minWidth: .zero,
          flex: .new(grow: 1, shrink: 1, basis: 24.rem),
        ),
        css('p').combine(bodyLarge),
        css('.actions').styles(margin: .only(top: 2.rem)),
      ]),
      css('.meet-components', [
        for (var i = 1; i <= 5; i++) ...[
          css('.select-target-$i').styles(position: .relative()),
          css('&:has(.select-trigger-$i:hover) .select-target-$i::before').styles(
            content: '',
            position: .absolute(left: (-10).px, top: (-10).px, right: (-10).px, bottom: (-10).px),
            zIndex: .new(-1),
            border: .all(color: primaryLight, width: 1.px),
            radius: .circular(8.px),
            backgroundColor: primaryFaded,
          ),
        ],
      ]),
      css('.meet-modes', [
        css('&').styles(flexWrap: .wrapReverse),
        css('& > div:first-child').styles(position: .relative()),
        css('.put-top span:last-child').styles(position: .absolute(), zIndex: .new(1)),
        css('.mode-highlight').styles(
          position: .absolute(bottom: 0.6.em, left: (-16).px, right: (-16).px),
          height: 3.2.em,
          border: .all(color: primaryLight, width: 2.px),
          radius: .circular(8.px),
          pointerEvents: .none,
          backgroundColor: primaryFaded,
        ),
      ]),
    ]),
  ];
}
