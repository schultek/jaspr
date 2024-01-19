import '../ui/html/html.dart';
import 'basic_types.dart';
import 'events/events_web.dart' if (dart.library.ffi) 'events/events_vm.dart';

export 'events/events_web.dart' if (dart.library.ffi) 'events/events_vm.dart'
    hide InputElement, TextAreaElement, SelectElement;

typedef EventCallback = void Function(Event event);
typedef EventCallbacks = Map<String, EventCallback>;

EventCallbacks events<V1, V2>({
  /// Listens to the 'click' event.
  VoidCallback? onClick,

  /// Listens to the 'input' event. The type of value depends on the input element.
  ///
  /// Type 'checkbox' or 'radio': bool?
  /// Type 'number': num?
  /// Type 'date' or 'dateTimeLocal': DateTime
  /// Type 'file': List<File>?
  /// Other type: String?
  ValueChanged<V1>? onInput,

  /// Listens to the 'change' event. The type of value depends on the input element.
  ///
  /// Type 'checkbox' or 'radio': bool?
  /// Type 'number': num?
  /// Type 'date' or 'dateTimeLocal': DateTime
  /// Type 'file': List<File>?
  /// Other type: String?
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
    print(target.runtimeType);
    var value = switch (target) {
      InputElement() => () {
          var type = InputType.values.where((v) => v.name == target.type).firstOrNull;
          return switch (type) {
            InputType.checkbox || InputType.radio => target.checked,
            InputType.number => target.valueAsNumber,
            InputType.date || InputType.dateTimeLocal => target.valueAsDate,
            InputType.file => target.files,
            _ => target.value,
          };
        }(),
      TextAreaElement() => target.value ?? '',
      SelectElement() => target.selectedOptions.map((o) => o.value).toList(),
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
