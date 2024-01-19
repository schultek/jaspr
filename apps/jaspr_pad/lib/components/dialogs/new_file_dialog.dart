import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../providers/edit_provider.dart';
import '../elements/button.dart';
import '../elements/dialog.dart';
import '../elements/textfield.dart';

class NewFileDialog extends StatefulComponent {
  const NewFileDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog(context, slotId: 'dialog', builder: (_) => NewFileDialog());
  }

  @override
  State createState() => NewFileDialogState();
}

class NewFileDialogState extends State<NewFileDialog> {
  String filename = '';

  bool filenameIsValid() {
    if (filename == 'index.html') {
      return context.read(editProjectProvider)?.htmlFile == null;
    } else if (filename == 'styles.css') {
      return context.read(editProjectProvider)?.cssFile == null;
    } else if (filename.endsWith('.dart')) {
      return filename != 'main.dart';
    }
    return false;
  }

  late final textField = TextField(
    label: 'Name',
    expand: true,
    onChange: (value) {
      setState(() {
        filename = value;
      });
    },
  );

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Dialog(
      title: 'New File',
      content: textField,
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
          disabled: !filenameIsValid(),
          onPressed: () {
            closeDialog(context, slotId: 'dialog', result: filename);
          },
        ),
      ],
    );
  }
}
