// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';

import '../../../components/link_card.dart';

class Features extends StatelessComponent {
  const Features({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section(id: 'features', [
      span(classes: 'caption text-gradient', [text('Features')]),
      h2([text('Comes with '), br(), text('Everything You Need')]),
      div(classes: 'feature-grid', [
        LinkCard(
          icon: 'milestone',
          title: 'Routing',
          description: 'Simple yet powerful routing system that works for all modes.',
          link: 'https://docs.page/schultek/jaspr/concepts/routing',
        ),
        LinkCard(
          icon: 'cloud-download',
          title: 'Data Fetching',
          description: 'Fetch data on the server during pre-rendering and sync data to the client.',
          link: 'https://docs.page/schultek/jaspr/concepts/data_fetching',
        ),
        LinkCard(
          icon: 'trophy',
          title: 'SEO',
          description: 'Optimize for search engines with pre-rendering and meta tags.',
          link: 'https://docs.page/schultek/jaspr/concepts/seo',
        ),
        LinkCard(
          icon: 'database',
          title: 'State Management',
          description: 'Use your favorite state management solution, like Riverpod or Provider.',
          link: 'https://docs.page/schultek/jaspr/eco/packages#state-management-packages',
        ),
        LinkCard(
          icon: 'picture-in-picture',
          title: 'Flutter Embedding',
          description: 'Embed Flutter widgets seamlessly in your Jaspr website.',
          link: 'https://docs.page/schultek/jaspr/going_further/flutter_embedding',
        ),
        LinkCard(
          icon: 'server',
          title: 'Custom Backends',
          description: 'Integrate Jaspr with any Dart backend, like Shelf, Serverpod or Dart Frog.',
          link: 'https://docs.page/schultek/jaspr/going_further/backend',
        ),
        LinkCard(
          icon: 'palette',
          title: 'Styling',
          description: 'Write styles in Dart, integrate with Tailwind or use any CSS based styling solution.',
          link: 'https://docs.page/schultek/jaspr/concepts/styling',
        ),
        LinkCard(
          icon: 'test-tube',
          title: 'Testing',
          description: 'Write tests for your components and pages with Jasprs testing library.',
          link: 'https://docs.page/schultek/jaspr/concepts/testing',
        ),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#features', [
      css('&')
          .box(padding: EdgeInsets.only(top: 10.rem))
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.center)
          .text(align: TextAlign.center),
      css('.feature-grid', [
        css('&')
            .box(
              maxWidth: 60.5.rem,
              margin: EdgeInsets.only(top: 3.rem, bottom: 4.rem),
              padding: EdgeInsets.symmetric(horizontal: 2.rem),
            )
            .flexbox(direction: FlexDirection.row, wrap: FlexWrap.wrap, gap: Gap.all(1.5.rem)),
        css('& > *')
            .flexItem(flex: Flex(grow: 1, shrink: 0, basis: FlexBasis(13.rem)))
            .box(boxSizing: BoxSizing.borderBox),
      ]),
    ]),
  ];
}
