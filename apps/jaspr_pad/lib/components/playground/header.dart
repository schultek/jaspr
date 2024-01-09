import 'package:jaspr/components.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../providers/logic_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/samples_provider.dart';
import '../dialogs/new_pad_dialog.dart';
import '../dialogs/reset_dialog.dart';
import '../elements/button.dart';
import '../elements/menu.dart';

class PlaygroundHeader extends StatelessComponent {
  const PlaygroundHeader({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield header(classes: [
      'mdc-elevation--z4'
    ], [
      div(
        classes: ['header-title'],
        [
          img(classes: ['logo'], src: "jaspr-192.png", alt: "JasprPad Logo"),
          span([text('JasprPad')]),
        ],
      ),
      div([
        Button(
          id: 'jnew-button',
          label: 'New Pad',
          icon: 'code',
          onPressed: () async {
            var result = await NewPadDialog.show(context);
            if (result == true) {
              context.read(logicProvider).newPad();
            }
          },
        ),
        Button(
          id: 'reset-button',
          label: 'Reset',
          icon: 'refresh',
          onPressed: () async {
            var result = await ResetDialog.show(context);
            if (result == true) {
              context.read(logicProvider).refresh();
            }
          },
        ),
        Button(
          id: 'jformat-button',
          label: 'Format',
          icon: 'format_align_left',
          onPressed: () {
            context.read(logicProvider).formatDartFiles();
          },
        ),
        Button(
          id: 'download-button',
          label: 'Download Project',
          icon: 'get_app',
          onPressed: () {
            context.read(logicProvider).downloadProject();
          },
        ),
      ]),
      Builder(builder: (context) sync* {
        var name = context.watch(projectNameProvider);
        yield div(classes: ['header-gist-name'], [text(name ?? '')]);
      }),
      Button(
        dense: true,
        raised: true,
        label: 'Tutorial',
        onPressed: () {
          context.read(logicProvider).selectTutorial();
        },
      ),
      div(styles: Styles.box(width: 10.px), []),
      SamplesMenuButton(),
      div(
        styles: Styles.combine([
          Styles.box(padding: EdgeInsets.symmetric(vertical: Unit.zero, horizontal: 10.px)),
          Styles.flexbox(
            justifyContent: JustifyContent.center,
            alignItems: AlignItems.center,
          ),
        ]),
        [
          a(href: 'https://github.com/schultek/jaspr', target: Target.blank, [
            img(
              src: 'https://findicons.com/files/icons/2779/simple_icons/128/github.png',
              styles: Styles.raw({'width': '40px', '-webkit-backface-visibility': 'hidden'}),
            ),
          ]),
        ],
      )
    ]);
  }
}

class SamplesMenuButton extends StatelessComponent with SyncProviderDependencies {
  const SamplesMenuButton({Key? key}) : super(key: key);

  @override
  Iterable<SyncProvider> get preloadDependencies => [syncSamplesProvider];

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var samples = context.watch(syncSamplesProvider).valueOrNull ?? [];
    print("SAMPLES $samples");

    yield Menu(
      items: [
        for (var sample in samples) MenuItem(label: sample.description),
      ],
      onItemSelected: (index) {
        context.read(logicProvider).selectSample(samples[index]);
      },
    );
  }
}
