import 'package:universal_web/web.dart' as web;

import '/dom.dart';
import '/jaspr.dart';
import 'type_checks.dart';

/// Helper function to provide typed event handlers to the `events` property of html components.
@optionalTypeArgs
Map<String, EventCallback> events<V>({
  /// Listens to the 'click' event.
  ///
  /// If the target element is an anchor (`<a>`) element,
  /// this overrides the default behavior of the link and
  /// doesn't visit the specified `href` when clicked.
  VoidCallback? onClick,

  /// Listens to the 'input' event.
  ///
  /// When providing a generic type for [V], it must be according to the target element:
  ///
  /// - `bool` for checkbox or radio input elements
  /// - `num` for number and range input elements
  /// - `DateTime` (UTC) for date, time, week, month and datetime-local input elements
  /// - `List<File>` for file input elements
  /// - `Color` for color input elements
  /// - `String` for all other input elements and textarea elements
  /// - `List<String>` for select elements
  /// - `Null` for all other elements
  ValueChanged<V>? onInput,

  /// Listens to the 'change' event.
  ///
  /// When providing a generic type for [V], it must be according to the target element:
  ///
  /// - `bool` for checkbox or radio input elements
  /// - `num` for number and range input elements
  /// - `DateTime` (UTC) for date, time, week, month and datetime-local input elements
  /// - `List<File>` for file input elements
  /// - `Color` for color input elements
  /// - `String` for all other input elements and textarea elements
  /// - `List<String>` for select elements
  /// - `Null` for all other elements
  ValueChanged<V>? onChange,
}) => {
  if (onClick != null)
    'click': (event) {
      if (kIsWeb && (event.target.isHtmlAnchorElement)) {
        event.preventDefault();
      }
      onClick();
    },
  if (onInput != null) 'input': _callWithValue('onInput', onInput),
  if (onChange != null) 'change': _callWithValue('onChange', onChange),
};

void Function(web.Event) _callWithValue<V>(String event, void Function(V) fn) {
  return (e) {
    final target = e.target;
    final value = switch (target) {
      web.HTMLInputElement() when target.isHtmlInputElement => () {
        final targetType = target.type;
        final type = InputType.values.where((v) => v.value == targetType).firstOrNull;
        return switch (type) {
          InputType.checkbox || InputType.radio => target.checked,
          InputType.number || InputType.range => target.valueAsNumber,
          InputType.date ||
          InputType.time ||
          InputType.week ||
          InputType.dateTimeLocal => DateTime.fromMillisecondsSinceEpoch(target.valueAsNumber.toInt(), isUtc: true),
          InputType.month => DateTime.utc(1970, target.valueAsNumber.toInt() + 1),
          InputType.file =>
            target.files != null
                ? List<web.File>.generate(
                    target.files!.length,
                    (index) => target.files!.item(index)!,
                    growable: false,
                  )
                : const <web.File>[],
          InputType.color => Color(target.value),
          _ => target.value,
        };
      }(),
      web.HTMLTextAreaElement() when target.isTextAreaElement => target.value,
      web.HTMLSelectElement() when target.isHtmlSelectElement => [
        for (final o in target.selectedOptions.toIterable())
          if (o.isHtmlOptionElement) (o as web.HTMLOptionElement).value,
      ],
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

extension on web.HTMLCollection {
  Iterable<web.Node> toIterable() sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)!;
    }
  }
}
