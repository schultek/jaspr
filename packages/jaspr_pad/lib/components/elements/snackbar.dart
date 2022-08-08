import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../adapters/mdc.dart';

final snackBarProvider = StateProvider<String?>((ref) => null);

class SnackBar extends StatefulComponent {
  const SnackBar({Key? key}) : super(key: key);

  @override
  State createState() => SnackBarState();
}

class SnackBarState extends State<SnackBar> {
  ProviderSubscription<String?>? _sub;
  MDCSnackbar? _snackbar;

  @override
  void initState() {
    super.initState();
    _sub = context.subscribe<String?>(snackBarProvider, (_, msg) {
      if (msg != null) _snackbar?.showMessage(msg);
    });
  }

  @override
  void dispose() {
    _sub?.close();
    super.dispose();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FindChildNode(
      onNodeFound: (node) {
        if (kIsWeb && _snackbar == null) {
          _snackbar = MDCSnackbar(node.nativeElement);
        }
      },
      child: DomComponent(
        tag: 'div',
        classes: ['mdc-snackbar'],
        children: [
          DomComponent(
            tag: 'div',
            classes: ['mdc-snackbar__surface'],
            children: [
              DomComponent(
                tag: 'div',
                classes: ['mdc-snackbar__label'],
                attributes: {'role': 'status', 'aria-live': 'polite'},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension SnackbarExtension on MDCSnackbar {
  void showMessage(String message) {
    labelText = message;
    open();
  }
}
