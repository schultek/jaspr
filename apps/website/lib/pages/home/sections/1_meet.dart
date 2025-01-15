// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart';
import 'package:website/constants/theme.dart';

import '../../../components/link_button.dart';
import '../../../components/modes_animation.dart';

class Meet extends StatelessComponent {
  const Meet({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section(id: 'meet', [
      div(classes: 'meet-section meet-components', [
        div([
          h3(classes: 'select-target-1', [text('Everything is a Component')]),
          p(classes: 'select-target-2', [
            text('Jaspr Components are the fundamental building blocks of any Jaspr website and work very similar '
            'to Flutter widgets. However, Jaspr renders actual HTML and CSS from your components, resulting in '
                'great SEO and fast loading times.')
          ]),
          div(classes: 'actions', [
            div(classes: 'select-target-3', [
              LinkButton.filled(label: 'Try out in Playground', icon: 'rocket', to: 'https://jasprpad.schultek.de'),
            ]),
            div(classes: 'select-target-4', [
              LinkButton.outlined(label: 'Read the Docs', icon: 'book-text', to: 'https://docs.page/schultek/jaspr/concepts/components'),
            ]),
          ])
        ]),
        div([
          p(classes: 'select-trigger-1', [text('Test Trigger 1')]),
          p(classes: 'select-trigger-2', [text('Test Trigger 2')]),
          p(classes: 'select-trigger-3', [text('Test Trigger 3')]),
          p(classes: 'select-trigger-4', [text('Test Trigger 4')]),
        ])
      ]),
      div(classes: 'meet-section meet-modes', [
        div([]),
        div([
          h3([text('Build '), br(), ModesAnimation(), br(), text(' using pure Dart')]),
          p([
            text(
                'Choose the rendering strategy you need. Generate static html at build time, pre-render pages dynamically on the server or build a single page application.')
          ]),
          div(classes: 'actions', [
            LinkButton.filled(label: 'Explore Modes', icon: 'book-open', to: 'https://docs.page/schultek/jaspr/get_started/modes'),
            LinkButton.outlined(label: 'See what others have built', icon: 'newspaper', to: 'https://discord.gg/Ej3Fkt5SGx'),
          ])
        ])
      ])
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#meet', [
      css('&').box(minHeight: 100.vh, padding: EdgeInsets.only(top: 2.rem)),
      css('.meet-section', [
        css('&')
            .box(
                maxWidth: 60.rem,
                margin: EdgeInsets.only(left: Unit.auto, right: Unit.auto, bottom: 8.rem),
                padding: EdgeInsets.symmetric(horizontal: 2.rem))
            .flexbox(direction: FlexDirection.row, alignItems: AlignItems.center, gap: Gap(column: 4.rem)),
        css('& > *').flexItem(flex: Flex(grow: 1)),
        css('p').combine(bodyLarge),
        css('.actions').box(margin: EdgeInsets.only(top: 2.rem)),
      ]),
      css('.meet-components', [
        for (var i = 1; i <= 4; i++) ...[
          css('.select-target-$i').box(position: Position.relative()),
          css('&:has(.select-trigger-$i:hover) .select-target-$i::before')
              .raw({'content': '""'})
              .box(
                position: Position.absolute(
                    left: (-10).px, top: (-10).px, right: (-10).px, bottom: (-10).px, zIndex: ZIndex(-1)),
                border: Border.all(BorderSide(color: primaryLight, width: 1.px)),
                radius: BorderRadius.circular(8.px),
              )
              .background(color: Colors.aliceBlue),
        ]
      ])
    ]),
  ];
}
