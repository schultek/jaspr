import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../adapters/mdc.dart';
import '../utils/node_reader.dart';

final _dialogStateProvider = StateProvider.family<_DialogState?, String>((ref, String id) => null);

class _DialogState<T> {
  final ComponentBuilder builder;
  final ValueChanged<T?> onResult;

  _DialogState(this.builder, this.onResult);
}

class DialogAction {
  final String label;
  final DialogResult result;

  DialogAction(this.label, this.result);
}

enum DialogResult { yes, no, ok, cancel }

Future<T?> showDialog<T>(BuildContext context, {required String slotId, required ComponentBuilder builder}) {
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
  const Dialog({required this.title, required this.content, required this.actions, super.key});

  final String title;
  final Component content;
  final List<Component> actions;

  @override
  Component build(BuildContext context) {
    return div(classes: 'mdc-dialog__container', [
      div(classes: 'mdc-dialog__surface', [
        h2(classes: 'mdc-dialog__title', [text(title)]),
        div(classes: 'mdc-dialog__content', [content]),
        footer(classes: 'mdc-dialog__actions', actions),
      ]),
    ]);
  }
}

class DialogSlot extends StatefulComponent {
  const DialogSlot({required this.slotId, super.key});

  final String slotId;

  @override
  State createState() => DialogState();
}

class DialogState extends State<DialogSlot> {
  MDCDialogOrStubbed? _dialog;
  ProviderSubscription<_DialogState?>? _sub;

  @override
  void initState() {
    super.initState();
    subscribeToOpenState();
  }

  void subscribeToOpenState() {
    _sub?.close();
    _sub = context.subscribe<_DialogState?>(_dialogStateProvider(component.slotId), (_, state) {
      if (state != null && _dialog != null && !_dialog!.isOpen) {
        context.binding.addPostFrameCallback(() {
          _dialog!.open();
        });
      } else if (state == null && _dialog != null && _dialog!.isOpen) {
        _dialog!.close();
      }
    });
  }

  @override
  void didUpdateComponent(covariant DialogSlot oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.slotId != component.slotId) {
      subscribeToOpenState();
    }
  }

  @override
  void dispose() {
    _sub?.close();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    var state = context.watch(_dialogStateProvider(component.slotId));

    return DomNodeReader(
      onNode: (node) {
        _dialog ??= MDCDialog(node);
        _dialog!.listen('MDCDialog:closed', (event) {
          context.read(_dialogStateProvider(component.slotId))?.onResult(null);
        });
      },
      child: div(
        classes: 'mdc-dialog',
        attributes: {'role': 'alertdialog', 'aria-modal': 'true'},
        [
          if (state != null) state.builder(context) else Dialog(content: text(''), title: '', actions: []),
          div(classes: 'mdc-dialog__scrim', []),
        ],
      ),
    );
  }
}
