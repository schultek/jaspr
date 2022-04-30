import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../adapters/mdc.dart';

final _dialogStateProvider = StateProvider.family<_DialogState?, String>((ref, String id) => null);

class _DialogState<T> {
  final SingleComponentBuilder builder;
  final ValueChanged<T?> onResult;

  _DialogState(this.builder, this.onResult);
}

class DialogAction {
  final String label;
  final DialogResult result;

  DialogAction(this.label, this.result);
}

enum DialogResult {
  yes,
  no,
  ok,
  cancel,
}

Future<T?> showDialog<T>(BuildContext context, {required String slotId, required SingleComponentBuilder builder}) {
  var completer = Completer<T?>();
  context.read(_dialogStateProvider(slotId).notifier).state = _DialogState(builder, (result) {
    if (!completer.isCompleted) {
      context.read(_dialogStateProvider(slotId).notifier).state = null;
      completer.complete(result);
    }
  });
  return completer.future;
}

void closeDialog(BuildContext context, {required String slotId, dynamic result}) {
  context.read(_dialogStateProvider(slotId))?.onResult(result);
}

class Dialog extends StatelessComponent {
  const Dialog({required this.title, required this.content, required this.actions, Key? key}) : super(key: key);

  final String title;
  final Component content;
  final List<Component> actions;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['mdc-dialog__container'],
      children: [
        DomComponent(
          tag: 'div',
          classes: ['mdc-dialog__surface'],
          children: [
            DomComponent(
              tag: 'h2',
              classes: ['mdc-dialog__title'],
              child: Text(title),
            ),
            DomComponent(
              tag: 'div',
              classes: ['mdc-dialog__content'],
              child: content,
            ),
            DomComponent(
              tag: 'footer',
              classes: ['mdc-dialog__actions'],
              children: actions,
            ),
          ],
        ),
      ],
    );
  }
}

class DialogSlot extends StatelessComponent {
  const DialogSlot({required this.slotId, Key? key}) : super(key: key);

  final String slotId;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var state = context.watch(_dialogStateProvider(slotId));

    yield DomComponent(
      tag: 'div',
      classes: ['mdc-dialog', if (state != null) 'mdc-dialog--open'],
      attributes: {'role': 'alertdialog', 'aria-modal': 'true'},
      children: [
        if (state != null) state.builder(context) else Dialog(content: Text(''), title: '', actions: []),
        DomComponent(
          tag: 'div',
          classes: ['mdc-dialog__scrim'],
        ),
      ],
    );
  }

  @override
  Element createElement() => DialogSlotElement(this);
}

class DialogSlotElement extends StatelessElement {
  DialogSlotElement(DialogSlot component) : super(component);

  @override
  DialogSlot get component => super.component as DialogSlot;

  ProviderSubscription<_DialogState?>? _sub;
  MDCDialog? _dialog;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    subscribeToOpenState();
  }

  void subscribeToOpenState() {
    _sub?.close();
    _sub = subscribe<_DialogState?>(_dialogStateProvider(component.slotId), (_, state) {
      if (state != null && _dialog != null && !_dialog!.isOpen) {
        _dialog!.open();
      } else if (state == null && _dialog != null && _dialog!.isOpen) {
        _dialog!.close();
      }
    });
  }

  @override
  void update(covariant Dialog newComponent) {
    var oldComponent = component;
    super.update(newComponent);
    if (oldComponent.slotId != component.slotId) {
      subscribeToOpenState();
    }
  }

  @override
  void unmount() {
    _sub?.close();
    super.unmount();
  }

  @override
  void render(DomBuilder b) {
    super.render(b);
    if (kIsWeb && _dialog == null) {
      _dialog = MDCDialog((children.first as DomElement).source);
      _dialog!.listen('MDCDialog:closed', (e) {
        read(_dialogStateProvider(component.slotId))?.onResult(null);
      });
    }
  }
}
