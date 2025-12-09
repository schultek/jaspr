import 'package:jaspr/jaspr.dart';

import '../elements/button.dart';
import '../elements/dialog.dart';

class DeleteFileDialog extends StatelessComponent {
  const DeleteFileDialog({required this.file, super.key});

  final String file;

  static Future<bool?> show(BuildContext context, String file) {
    return showDialog(
      context,
      slotId: 'dialog',
      builder: (_) => DeleteFileDialog(file: file),
    );
  }

  @override
  Component build(BuildContext context) {
    return Dialog(
      title: 'Delete File',
      content: .text('Delete file \'$file\'? This can\'t be undone.'),
      actions: [
        Button(
          label: 'Cancel',
          dialog: true,
          onPressed: () {
            closeDialog(context, slotId: 'dialog');
          },
        ),
        Button(
          label: 'Delete',
          dialog: true,
          onPressed: () {
            closeDialog(context, slotId: 'dialog', result: true);
          },
        ),
      ],
    );
  }
}
