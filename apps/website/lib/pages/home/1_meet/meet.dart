import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

import '../../../components/code_window/code_window.dart';
import '../../../components/link_button.dart';
import 'components/modes_animation.dart';

class Meet extends StatelessComponent {
  const Meet({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section(id: 'meet', [
      div(classes: 'meet-section meet-components', [
        div([
          h3(classes: 'select-target-1', [text('Everything is a Component')]),
          p(classes: 'select-target-2', [
            text('Jaspr Components are the fundamental building blocks of any Jaspr website and look very similar '
                'to Flutter widgets. However, Jaspr renders actual HTML and CSS from your components, resulting in '
                'great SEO and fast loading times.')
          ]),
          div(classes: 'actions select-target-3', [
            div(classes: 'select-target-4', [
              LinkButton.filled(
                  label: 'Try out in Playground', icon: 'rocket', to: 'https://jasprpad.schultek.de/?sample=counter'),
            ]),
            div(classes: 'select-target-5', [
              LinkButton.outlined(
                  label: 'Read the Docs',
                  icon: 'book-text',
                  to: 'https://docs.page/schultek/jaspr/concepts/components'),
            ]),
          ])
        ]),
        div([
          CodeWindow(name: 'app.dart', inactiveName: 'button.dart', selectable: true, source: '''
          import 'package:jaspr/jaspr.dart';
          import 'button.dart';
          
          class App extends StatelessComponent {
            const App({super.key});

            @override
            Iterable<Component> build(BuildContext context) sync* {
              yield h2([text('Everything is a Component')]);
              yield p([text('Jaspr Components are the fundamental building blocks ...')]);

              yield div(classes: 'actions', [
                Button(
                  primary: true,
                  label: 'Try out in Playground', 
                  icon: 'rocket',
                ),
                Button(
                  label: 'Read the Docs', 
                  icon: 'book-text',
                ),
              ]);
            }
          }
          ''', lineClasses: {
            8: 'select-trigger-1',
            9: 'select-trigger-2',
            11: 'select-trigger-3',
            12: 'select-trigger-4',
            13: 'select-trigger-4',
            14: 'select-trigger-4',
            15: 'select-trigger-4',
            16: 'select-trigger-4',
            17: 'select-trigger-5',
            18: 'select-trigger-5',
            19: 'select-trigger-5',
            20: 'select-trigger-5',
            21: 'select-trigger-3'
          }),
        ])
      ]),
      div(classes: 'meet-section meet-modes', [
        div([
          CodeWindow(
              name: 'pubspec.yaml',
              inactiveName: 'main.dart',
              source: '''
          name: my_awesome_website
          description: A new Jaspr site.

          environment:  
            sdk: ">=3.0.0 <4.0.0"

          dependencies:  
            jaspr: ^0.16.0
            jaspr_router: ^0.2.3
            
          dev_dependencies:
            jaspr_builders: ^0.16.0
            jaspr_web_compilers: ^4.1.0
            jaspr_lints: ^0.2.1

          jaspr:
            mode: static
          ''',
              language: 'yaml',
              lineClasses: {15: 'put-top', 16: 'put-top jaspr-mode'}),
          div(classes: 'mode-highlight', []),
        ]),
        div([
          h3([text('Build '), br(), ModesAnimation(), br(), text(' using pure Dart')]),
          p([
            text(
                'Choose the rendering strategy you need. Generate static html at build time, pre-render pages dynamically on the server or build a single page application.')
          ]),
          div(classes: 'actions', [
            LinkButton.filled(
                label: 'Explore Modes', icon: 'book-open', to: 'https://docs.page/schultek/jaspr/get_started/modes'),
            LinkButton.outlined(
                label: 'See what others have built', icon: 'newspaper', to: 'https://discord.gg/Ej3Fkt5SGx'),
          ])
        ])
      ])
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#meet', [
      css('&')
          .box(minHeight: 100.vh, padding: EdgeInsets.only(top: 2.rem, left: 4.rem, right: 4.rem))
          .flexbox(direction: FlexDirection.column, gap: Gap(row: 10.rem), alignItems: AlignItems.center),
      css('.meet-section', [
        css('&').box(maxWidth: maxContentWidth).flexbox(
              direction: FlexDirection.row,
              alignItems: AlignItems.center,
              wrap: FlexWrap.wrap,
              gap: Gap(column: 4.rem, row: 4.rem),
            ),
        css('& > *').flexItem(flex: Flex(grow: 1, shrink: 0, basis: FlexBasis(24.rem))).box(minWidth: Unit.zero),
        css('p').combine(bodyLarge),
        css('.actions').box(margin: EdgeInsets.only(top: 2.rem)),
      ]),
      css('.meet-components', [
        for (var i = 1; i <= 5; i++) ...[
          css('.select-target-$i').box(position: Position.relative()),
          css('&:has(.select-trigger-$i:hover) .select-target-$i::before')
              .raw({'content': '""'})
              .box(
                position: Position.absolute(
                    left: (-10).px, top: (-10).px, right: (-10).px, bottom: (-10).px, zIndex: ZIndex(-1)),
                border: Border.all(BorderSide(color: primaryLight, width: 1.px)),
                radius: BorderRadius.circular(8.px),
              )
              .background(color: primaryFaded),
        ]
      ]),
      css('.meet-modes', [
        css('&').flexbox(wrap: FlexWrap.wrapReverse),
        css('& > div:first-child').box(position: Position.relative()),
        css('.put-top span:last-child').box(position: Position.absolute(zIndex: ZIndex(1))),
        css('.mode-highlight')
            .box(
                position: Position.absolute(bottom: 0.8.em, left: (-16).px, right: (-16).px),
                height: 2.8.em,
                radius: BorderRadius.circular(8.px),
                border: Border.all(
                  BorderSide(color: primaryLight, width: 2.px),
                ))
            .background(color: primaryFaded).raw({'pointer-events': 'none'}),
      ]),
    ]),
  ];
}
