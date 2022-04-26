import 'package:jaspr/jaspr.dart';

import '../elements/snackbar.dart';
import '../elements/splitter.dart';
import 'panels/editor_panel.dart';
import 'panels/output_panel.dart';

class MainSection extends StatelessComponent {
  const MainSection({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'section',
      classes: ['main-section'],
      children: [
        DomComponent(
          tag: 'div',
          classes: ['panels'],
          child: Splitter(
            children: [
              EditorPanel(),
              OutputPanel(),
            ],
          ),
        ),
        SnackBar(),
      ],
    );
  }
}
