import 'package:web/web.dart' if (dart.library.io) 'events_vm.dart';

import '../../components/html/html.dart';
import '../basic_types.dart';

export 'package:web/web.dart' if (dart.library.io) 'events_vm.dart' show Event;

typedef EventCallback = void Function(Event event);
typedef EventCallbacks = Map<String, EventCallback>;

/// Helper function to provide typed event handlers to the `events` property of html components.
EventCallbacks events<V1, V2>({
  /// Listens to the 'click' event.
  VoidCallback? onClick,

  /// Listens to the 'input' event. When providing a generic type for [value], it must be according to the target element:
  /// - `bool?` for checkbox or radio input elements
  /// - `num?` for number input elements
  /// - `DateTime` for date input elements
  /// - `List<File>?` for file input elements
  /// - `List<String>` for select elements
  /// - `String` for text input and textarea elements
  /// - `Null` for all other elements
  ValueChanged<V1>? onInput,

  /// Listens to the 'change' event. When providing a generic type for [value], it must be according to the target element:
  /// - `bool?` for checkbox or radio input elements
  /// - `num?` for number input elements
  /// - `DateTime` for date input elements
  /// - `List<File>?` for file input elements
  /// - `List<String>` for select elements
  /// - `String` for text input and textarea elements
  /// - `Null` for all other elements
  ValueChanged<V2>? onChange,
}) =>
    {
      if (onClick != null) 'click': (_) => onClick(),
      if (onInput != null) 'input': _callWithValue('onInput', onInput),
      if (onChange != null) 'change': _callWithValue('onChange', onChange),
    };

void Function(Event) _callWithValue<V>(String event, void Function(V) fn) {
  return (e) {
    var target = e.target;
    var value = switch (target) {
      HTMLInputElement() => () {
          var type = InputType.values.where((v) => v.name == target.type).firstOrNull;
          return switch (type) {
            InputType.checkbox || InputType.radio => target.checked,
            InputType.number => target.valueAsNumber,
            InputType.date || InputType.dateTimeLocal => target.valueAsDate,
            InputType.file => target.files,
            _ => target.value,
          };
        }(),
      HTMLTextAreaElement() => target.value,
      HTMLSelectElement() =>
        target.selectedOptions.toIterable().map((o) => o is HTMLOptionElement ? o.value : null).toList(),
      _ => null,
    };
    assert(() {
      if (value is! V) {
        throw 'Tried to call the provided "void Function($V value)" $event callback with a value of type "${value.runtimeType}". Make sure you use the correct input type or '
            'change the $event method to a function of type "void Function(${value.runtimeType} value)".';
      }
      return true;
    }());
    fn(value as V);
  };
}

extension on HTMLCollection {
  Iterable<Node> toIterable() sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)!;
    }
  }
}
