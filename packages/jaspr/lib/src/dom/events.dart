import 'package:universal_web/web.dart' as web;

import '/jaspr.dart';
import 'html/html.dart';
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
  /// - `bool?` for checkbox or radio input elements
  /// - `num?` for number input elements
  /// - `DateTime` for date input elements
  /// - `List<File>?` for file input elements
  /// - `List<String>` for select elements
  /// - `String` for text input and textarea elements
  /// - `Null` for all other elements
  ValueChanged<V>? onInput,

  /// Listens to the 'change' event.
  ///
  /// When providing a generic type for [V], it must be according to the target element:
  ///
  /// - `bool?` for checkbox or radio input elements
  /// - `num?` for number input elements
  /// - `DateTime` for date input elements
  /// - `List<File>?` for file input elements
  /// - `List<String>` for select elements
  /// - `String` for text input and textarea elements
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
        final type = InputType.values.where((v) => v.name == targetType).firstOrNull;
        return switch (type) {
          InputType.checkbox || InputType.radio => target.checked,
          InputType.number => target.valueAsNumber,
          InputType.date || InputType.dateTimeLocal => target.valueAsDate,
          InputType.file => target.files,
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
