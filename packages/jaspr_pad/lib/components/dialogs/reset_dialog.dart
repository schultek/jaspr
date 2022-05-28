import 'package:jaspr/jaspr.dart';

import '../elements/button.dart';
import '../elements/dialog.dart';

class ResetDialog extends StatelessComponent {
  const ResetDialog({Key? key}) : super(key: key);

  static Future<bool?> show(BuildContext context) {
    return showDialog(context, slotId: 'dialog', builder: (_) => ResetDialog());
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Dialog(
      title: 'Reset Pad',
      content: Text('Discard changes to the current pad?'),
      actions: [
        Button(
          label: 'Cancel',
          dialog: true,
          onPressed: () {
            closeDialog(context, slotId: 'dialog');
          },
        ),
        Button(
          label: 'Reset',
          dialog: true,
          onPressed: () {
            closeDialog(context, slotId: 'dialog', result: true);
          },
        ),
      ],
    );
  }
}
