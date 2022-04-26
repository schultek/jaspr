import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../adapters/mdc.dart';

final snackBarProvider = StateProvider<String?>((ref) => null);

class SnackBar extends StatelessComponent {
  const SnackBar({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['mdc-snackbar'],
      children: [
        DomComponent(
          tag: 'div',
          classes: ['mdc-snackbar__surface'],
          children: [
            DomComponent(
                tag: 'div', classes: ['mdc-snackbar__label'], attributes: {'role': 'status', 'aria-live': 'polite'}),
          ],
        ),
      ],
    );
  }

  @override
  Element createElement() => SnackBarElement(this);
}

class SnackBarElement extends StatelessElement {
  SnackBarElement(SnackBar component) : super(component);

  ProviderSubscription<String?>? _sub;
  MDCSnackbar? _snackbar;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    _sub = subscribe<String?>(snackBarProvider, (_, msg) {
      if (msg != null) _snackbar?.showMessage(msg);
    });
  }

  @override
  void unmount() {
    _sub?.close();
    super.unmount();
  }

  @override
  void render(DomBuilder b) {
    if (_snackbar == null) {
      super.render(b);
      if (kIsWeb) {
        _snackbar = MDCSnackbar((children.first as DomElement).source);
      }
    } else {
      b.skipNode();
    }
  }
}

extension SnackbarExtension on MDCSnackbar {
  void showMessage(String message) {
    labelText = message;
    open();
  }
}
