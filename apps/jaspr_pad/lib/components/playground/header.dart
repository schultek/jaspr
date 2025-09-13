import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../providers/logic_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/samples_provider.dart';
import '../dialogs/new_pad_dialog.dart';
import '../dialogs/reset_dialog.dart';
import '../elements/button.dart';
import '../elements/menu.dart';

class PlaygroundHeader extends StatelessComponent {
  const PlaygroundHeader({super.key});

  @override
  Component build(BuildContext context) {
    return header(classes: 'mdc-elevation--z4', [
      div(classes: 'header-title', [
        img(classes: 'logo', src: "jaspr-192.png", alt: "JasprPad Logo"),
        span([text('JasprPad')]),
      ]),
      div(styles: Styles(whiteSpace: WhiteSpace.noWrap), [
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
      Builder(
        builder: (context) {
          var name = context.watch(projectNameProvider);
          return div(classes: 'header-gist-name', [text(name ?? '')]);
        },
      ),
      Button(
        dense: true,
        raised: true,
        label: 'Tutorial',
        onPressed: () {
          context.read(logicProvider).selectTutorial();
        },
      ),
      div(styles: Styles(width: 10.px), []),
      SamplesMenuButton(),
      div(
        styles: Styles(
          display: Display.flex,
          padding: Padding.symmetric(vertical: Unit.zero, horizontal: 10.px),
          justifyContent: JustifyContent.center,
          alignItems: AlignItems.center,
        ),
        [
          a(href: 'https://github.com/schultek/jaspr', target: Target.blank, [
            img(
              src: 'https://findicons.com/files/icons/2779/simple_icons/128/github.png',
              styles: Styles(width: 40.px, raw: {'-webkit-backface-visibility': 'hidden'}),
            ),
          ]),
        ],
      ),
    ]);
  }
}

class SamplesMenuButton extends StatelessComponent with SyncProviderDependencies {
  const SamplesMenuButton({super.key});

  @override
  Iterable<SyncProvider> get preloadDependencies => [syncSamplesProvider];

  @override
  Component build(BuildContext context) {
    var samples = context.watch(syncSamplesProvider).valueOrNull ?? [];

    return Menu(
      items: [for (var sample in samples) MenuItem(label: sample.description)],
      onItemSelected: (index) {
        context.read(logicProvider).selectSample(samples[index]);
      },
    );
  }
}
