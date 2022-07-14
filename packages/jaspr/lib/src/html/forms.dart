import '../../jaspr.dart';

/// The &lt;button&gt; HTML element is an interactive element activated by a user with a mouse, keyboard, finger, voice command, or other assistive technology. Once activated, it then performs a programmable action, such as submitting a form or opening a dialog.
///
/// - [autofocus]: Specifies that the button should have input focus when the page loads. Only one element in a document can have this attribute.
/// - [disabled]: Prevents the user from interacting with the button: it cannot be pressed or focused.
/// - [type]: The default behavior of the button.
Component button({bool? autofocus, bool? disabled, ButtonType? type, Key? key, String? id, Iterable<String>? classes, Map<String, String>? styles, Map<String, String>? attributes, Map<String, EventCallback>? events, Component? child, List<Component>? children}) {
  return DomComponent(
    tag: 'button',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (autofocus == true) 'autofocus': '',
      if (disabled == true) 'disabled': '',
      if (type != null) 'type': type.value,
    },
    events: events,
    child: child,
    children: children,
  );
}


/// Defines the default behavior of a button.
enum ButtonType {
  /// The button submits the form data to the server. This is the default if the attribute is not specified for buttons associated with a &lt;form&gt;, or if the attribute is an empty or invalid value.
  submit('submit'),
  /// The button resets all the controls to their initial values, like &lt;input type="reset"&gt;. (This behavior tends to annoy users.)
  reset('reset'),
  /// The button has no default behavior, and does nothing when pressed by default. It can have client-side scripts listen to the element's events, which are triggered when the events occur.
  button('button');

  final String value;
  const ButtonType(this.value);
}
