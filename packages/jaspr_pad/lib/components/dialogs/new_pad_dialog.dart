import 'package:jaspr/jaspr.dart';

import '../elements/button.dart';
import '../elements/dialog.dart';

class NewPadDialog extends StatelessComponent {
  const NewPadDialog({Key? key}) : super(key: key);

  static Future<bool?> show(BuildContext context) {
    return showDialog(context, slotId: 'dialog', builder: (_) => NewPadDialog());
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Dialog(
      title: 'Create New Pad',
      content: Text('This will discard the current pad.'),
      actions: [
        Button(
          label: 'Cancel',
          dialog: true,
          onPressed: () {
            closeDialog(context, slotId: 'dialog');
          },
        ),
        Button(
          label: 'Create',
          dialog: true,
          onPressed: () {
            closeDialog(context, slotId: 'dialog', result: true);
          },
        ),
      ],
    );
  }
}
