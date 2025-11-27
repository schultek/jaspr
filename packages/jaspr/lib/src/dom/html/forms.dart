// GENERATED FILE - DO NOT EDIT
// Generated from packages/jaspr/tool/generate_html.dart
//
// dart format off
// ignore_for_file: camel_case_types

part of 'html.dart';

/// {@template jaspr.html.button}
/// The &lt;button&gt; HTML element is an interactive element activated by a user with a mouse, keyboard, finger, voice command, or other assistive technology. Once activated, it then performs a programmable action, such as submitting a form or opening a dialog.
/// {@endtemplate}
final class button extends StatelessComponent {
  /// {@macro jaspr.html.button}
  const button(
    this.children, {
    this.autofocus = false,
    this.disabled = false,
    this.type,
    this.onClick,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Specifies that the button should have input focus when the page loads. Only one element in a document can have this attribute.
  final bool autofocus;

  /// Prevents the user from interacting with the button: it cannot be pressed or focused.
  final bool disabled;

  /// The default behavior of the button.
  final ButtonType? type;

  /// Callback for the 'click' event.
  final VoidCallback? onClick;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'button',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        if (autofocus) 'autofocus': '',
        if (disabled) 'disabled': '',
        'type': ?type?.value,
      },
      events: {
        ...?events,
        ..._events<void>(onClick: onClick),
      },
      children: children,
    );
  }
}

/// Defines the default behavior of a button.
enum ButtonType {
  /// The button submits the form data to the server. This is the default if the attribute is not specified for buttons associated with a &lt;form&gt;, or if the attribute is an empty or invalid value.
  submit('submit'),

  /// The button resets all the controls to their initial values, like &lt;input type="reset"&gt;. (This behavior tends to annoy users.)
  reset('reset'),

  /// The button has no default behavior, and does nothing when pressed by default. It can have client-side scripts listen to the element's events, which are triggered when the events occur.
  button('button');

  const ButtonType(this.value);

  final String value;
}

/// {@template jaspr.html.form}
/// The &lt;form&gt; HTML element represents a document section containing interactive controls for submitting information.
/// {@endtemplate}
final class form extends StatelessComponent {
  /// {@macro jaspr.html.form}
  const form(
    this.children, {
    this.action,
    this.method,
    this.encType,
    this.autoComplete,
    this.name,
    this.noValidate = false,
    this.target,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The URL that processes the form submission. This value can be overridden by a formaction attribute on a &lt;button&gt;, &lt;input type="submit"&gt;, or &lt;input type="image"&gt; element. This attribute is ignored when method="dialog" is set.
  final String? action;

  /// The HTTP method to submit the form with.
  ///
  /// This value is overridden by formmethod attributes on &lt;button&gt;, &lt;input type="submit"&gt;, or &lt;input type="image"&gt; elements.
  final FormMethod? method;

  /// If the value of the method attribute is post, enctype is the MIME type of the form submission.
  final FormEncType? encType;

  /// Indicates whether input elements can by default have their values automatically completed by the browser. autocomplete attributes on form elements override it on &lt;form&gt;.
  final AutoComplete? autoComplete;

  /// The name of the form. The value must not be the empty string, and must be unique among the form elements in the forms collection that it is in, if any.
  final String? name;

  /// Indicates that the form shouldn't be validated when submitted. If this attribute is not set (and therefore the form is validated), it can be overridden by a formnovalidate attribute on a &lt;button&gt;, &lt;input type="submit"&gt;, or &lt;input type="image"&gt; element belonging to the form.
  final bool noValidate;

  /// Indicates where to display the response after submitting the form. In HTML 4, this is the name/keyword for a frame. In HTML5, it is a name/keyword for a browsing context (for example, tab, window, or iframe).
  final Target? target;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'form',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'action': ?action,
        'method': ?method?.value,
        'enctype': ?encType?.value,
        'autocomplete': ?autoComplete?.value,
        'name': ?name,
        if (noValidate) 'novalidate': '',
        'target': ?target?.value,
      },
      events: events,
      children: children,
    );
  }
}

/// The HTTP method to submit a form with.
enum FormMethod {
  /// The POST method; form data sent as the request body.
  post('post'),

  /// The GET method; form data appended to the action URL with a ? separator. Use this method when the form has no side-effects.
  get('get'),

  /// When the form is inside a &lt;dialog&gt;, closes the dialog and throws a submit event on submission without submitting data or clearing the form.
  dialog('dialog');

  const FormMethod(this.value);

  final String value;
}

/// The MIME type of a form submission.
enum FormEncType {
  /// The default value
  formUrlEncoded('application/x-www-form-urlencoded'),

  /// Use this if the form contains &lt;input&gt; elements with type=file.
  multiPart('multipart/form-data'),

  /// Introduced by HTML5 for debugging purposes.
  text('text/plain');

  const FormEncType(this.value);

  final String value;
}

/// Indicates whether input elements can by default have their values automatically completed by the browser. autocomplete attributes on form elements override it on &lt;form&gt;.
enum AutoComplete {
  /// The browser may not automatically complete entries.
  off('off'),

  /// The browser may automatically complete entries.
  on('on');

  const AutoComplete(this.value);

  final String value;
}

/// {@template jaspr.html.input}
/// The &lt;input&gt; HTML element is used to create interactive controls for web-based forms in order to accept data from the user; a wide variety of types of input data and control widgets are available, depending on the device and user agent. The &lt;input&gt; element is one of the most powerful and complex in all of HTML due to the sheer number of combinations of input types and attributes.
/// {@endtemplate}
@optionalTypeArgs
final class input<T> extends StatelessComponent {
  /// {@macro jaspr.html.input}
  const input({
    this.type,
    this.name,
    this.value,
    this.disabled = false,
    this.checked,
    this.indeterminate,
    this.onInput,
    this.onChange,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Defines how an &lt;input&gt; works. If this attribute is not specified, the default type adopted is text.
  final InputType? type;

  /// Name of the form control. Submitted with the form as part of a name/value pair.
  final String? name;

  /// The value of the control.
  final String? value;

  /// Indicates that the user should not be able to interact with the input. Disabled inputs are typically rendered with a dimmer color or using some other form of indication that the field is not available for use.
  final bool disabled;

  /// Specifies whether the form control is checked or not. Applies only to checkbox and radio inputs.
  final bool? checked;

  /// Specifies whether the checkbox control is indeterminate or not. Applies only to checkbox inputs.
  final bool? indeterminate;

  /// Callback for the 'input' event. The type of [value] depends on [type].
  final ValueChanged<T>? onInput;

  /// Callback for the 'change' event. The type of [value] depends on [type].
  final ValueChanged<T>? onChange;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'input',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'type': ?type?.value,
        'name': ?name,
        'value': ?value,
        if (disabled) 'disabled': '',
        'checked': ?_explicitBool(checked),
        'indeterminate': ?_explicitBool(indeterminate),
      },
      events: {
        ...?events,
        ..._events(onInput: onInput, onChange: onChange),
      },
    );
  }
}

/// The type for an &lt;input&gt; element.
enum InputType {
  /// A push button with no default behavior displaying the value of the value attribute, empty by default.
  button('button'),

  /// A check box allowing single values to be selected/deselected.
  checkbox('checkbox'),

  /// A control for specifying a color; opening a color picker when active in supporting browsers.
  color('color'),

  /// A control for entering a date (year, month, and day, with no time). Opens a date picker or numeric wheels for year, month, day when active in supporting browsers.
  date('date'),

  /// A control for entering a date and time, with no time zone. Opens a date picker or numeric wheels for date- and time-components when active in supporting browsers.
  dateTimeLocal('datetime-local'),

  /// A field for editing an email address. Looks like a text input, but has validation parameters and relevant keyboard in supporting browsers and devices with dynamic keyboards.
  email('email'),

  /// A control that lets the user select a file. Use the accept attribute to define the types of files that the control can select.
  file('file'),

  /// A control that is not displayed but whose value is submitted to the server.
  hidden('hidden'),

  /// A graphical submit button. Displays an image defined by the src attribute. The alt attribute displays if the image src is missing.
  image('image'),

  /// A control for entering a month and year, with no time zone.
  month('month'),

  /// A control for entering a number. Displays a spinner and adds default validation when supported. Displays a numeric keypad in some devices with dynamic keypads.
  number('number'),

  /// A single-line text field whose value is obscured. Will alert user if site is not secure.
  password('password'),

  /// A radio button, allowing a single value to be selected out of multiple choices with the same name value.
  radio('radio'),

  /// A control for entering a number whose exact value is not important. Displays as a range widget defaulting to the middle value. Used in conjunction min and max to define the range of acceptable values.
  range('range'),

  /// A button that resets the contents of the form to default values. Not recommended.
  reset('reset'),

  /// A single-line text field for entering search strings. Line-breaks are automatically removed from the input value. May include a delete icon in supporting browsers that can be used to clear the field. Displays a search icon instead of enter key on some devices with dynamic keypads.
  search('search'),

  /// A button that submits the form.
  submit('submit'),

  /// A control for entering a telephone number. Displays a telephone keypad in some devices with dynamic keypads.
  tel('tel'),

  /// The default value. A single-line text field. Line-breaks are automatically removed from the input value.
  text('text'),

  /// A control for entering a time value with no time zone.
  time('time'),

  /// A field for entering a URL. Looks like a text input, but has validation parameters and relevant keyboard in supporting browsers and devices with dynamic keyboards.
  url('url'),

  /// A control for entering a date consisting of a week-year number and a week number with no time zone.
  week('week');

  const InputType(this.value);

  final String value;
}

/// {@template jaspr.html.label}
/// The &lt;label&gt; HTML element represents a caption for an item in a user interface.
/// {@endtemplate}
final class label extends StatelessComponent {
  /// {@macro jaspr.html.label}
  const label(
    this.children, {
    this.htmlFor,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The value of the for attribute must be a single id for a labelable form-related element in the same document as the &lt;label&gt; element. So, any given label element can be associated with only one form control.
  final String? htmlFor;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'label',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {...?attributes, 'for': ?htmlFor},
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.datalist}
/// The &lt;datalist&gt; HTML element contains a set of &lt;option&gt; elements that represent the permissible or recommended options available to choose from within other controls.
/// {@endtemplate}
final class datalist extends StatelessComponent {
  /// {@macro jaspr.html.datalist}
  const datalist(
    this.children, {
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'datalist',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.legend}
/// The &lt;legend&gt; HTML element represents a caption for the content of its parent &lt;fieldset&gt;.
/// {@endtemplate}
final class legend extends StatelessComponent {
  /// {@macro jaspr.html.legend}
  const legend(
    this.children, {
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'legend',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.meter}
/// The &lt;meter&gt; HTML element represents either a scalar value within a known range or a fractional value.
/// {@endtemplate}
final class meter extends StatelessComponent {
  /// {@macro jaspr.html.meter}
  const meter(
    this.children, {
    this.value,
    this.min,
    this.max,
    this.low,
    this.high,
    this.optimum,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The current numeric value. This must be between the minimum and maximum values (min attribute and max attribute) if they are specified. If unspecified or malformed, the value is 0. If specified, but not within the range given by the min attribute and max attribute, the value is equal to the nearest end of the range.
  final double? value;

  /// The lower numeric bound of the measured range. This must be less than the maximum value (max attribute), if specified. If unspecified, the minimum value is 0.
  final double? min;

  /// The upper numeric bound of the measured range. This must be greater than the minimum value (min attribute), if specified. If unspecified, the maximum value is 1.
  final double? max;

  /// The upper numeric bound of the low end of the measured range. This must be greater than the minimum value (min attribute), and it also must be less than the high value and maximum value (high attribute and max attribute, respectively), if any are specified. If unspecified, or if less than the minimum value, the low value is equal to the minimum value.
  final double? low;

  /// The lower numeric bound of the high end of the measured range. This must be less than the maximum value (max attribute), and it also must be greater than the low value and minimum value (low attribute and min attribute, respectively), if any are specified. If unspecified, or if greater than the maximum value, the high value is equal to the maximum value.
  final double? high;

  /// Indicates the optimal numeric value. It must be within the range (as defined by the min attribute and max attribute). When used with the low attribute and high attribute, it gives an indication where along the range is considered preferable. For example, if it is between the min attribute and the low attribute, then the lower range is considered preferred. The browser may color the meter's bar differently depending on whether the value is less than or equal to the optimum value.
  final double? optimum;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'meter',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'value': ?value?.toString(),
        'min': ?min?.toString(),
        'max': ?max?.toString(),
        'low': ?low?.toString(),
        'high': ?high?.toString(),
        'optimum': ?optimum?.toString(),
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.progress}
/// The &lt;progress&gt; HTML element displays an indicator showing the completion progress of a task, typically displayed as a progress bar.
/// {@endtemplate}
final class progress extends StatelessComponent {
  /// {@macro jaspr.html.progress}
  const progress(
    this.children, {
    this.value,
    this.max,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// This attribute specifies how much of the task that has been completed. It must be a valid floating point number between 0 and max, or between 0 and 1 if max is omitted. If there is no value attribute, the progress bar is indeterminate; this indicates that an activity is ongoing with no indication of how long it is expected to take.
  final double? value;

  /// This attribute describes how much work the task indicated by the progress element requires. The max attribute, if present, must have a value greater than 0 and be a valid floating point number. The default value is 1.
  final double? max;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'progress',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'value': ?value?.toString(),
        'max': ?max?.toString(),
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.optgroup}
/// The &lt;optgroup&gt; HTML element creates a grouping of options within a &lt;select&gt; element.
/// {@endtemplate}
final class optgroup extends StatelessComponent {
  /// {@macro jaspr.html.optgroup}
  const optgroup(
    this.children, {
    required this.label,
    this.disabled = false,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The name of the group of options, which the browser can use when labeling the options in the user interface.
  final String label;

  /// If this attribute is set, none of the items in this option group is selectable. Often browsers grey out such control and it won't receive any browsing events, like mouse clicks or focus-related ones.
  final bool disabled;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'optgroup',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'label': label,
        if (disabled) 'disabled': '',
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.option}
/// The &lt;option&gt; HTML element is used to define an item contained in a &lt;select&gt;, an &lt;optgroup&gt;, or a &lt;datalist&gt; element. As such, &lt;option&gt; can represent menu items in popups and other lists of items in an HTML document.
/// {@endtemplate}
final class option extends StatelessComponent {
  /// {@macro jaspr.html.option}
  const option(
    this.children, {
    this.label,
    this.value,
    this.selected = false,
    this.disabled = false,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// This attribute is text for the label indicating the meaning of the option. If the label attribute isn't defined, its value is that of the element text content.
  final String? label;

  /// The content of this attribute represents the value to be submitted with the form, should this option be selected. If this attribute is omitted, the value is taken from the text content of the option element.
  final String? value;

  /// Indicates that the option is initially selected. If the &lt;option&gt; element is the descendant of a &lt;select&gt; element whose multiple attribute is not set, only one single &lt;option&gt; of this &lt;select&gt; element may have the selected attribute.
  final bool selected;

  /// If this attribute is set, this option is not checkable. Often browsers grey out such control and it won't receive any browsing event, like mouse clicks or focus-related ones. If this attribute is not set, the element can still be disabled if one of its ancestors is a disabled &lt;optgroup&gt; element.
  final bool disabled;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'option',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'label': ?label,
        'value': ?value,
        if (selected) 'selected': '',
        if (disabled) 'disabled': '',
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.select}
/// The &lt;select&gt; HTML element represents a control that provides a menu of options.
/// {@endtemplate}
final class select extends StatelessComponent {
  /// {@macro jaspr.html.select}
  const select(
    this.children, {
    this.name,
    this.value,
    this.multiple = false,
    this.required = false,
    this.disabled = false,
    this.autofocus = false,
    this.autocomplete,
    this.size,
    this.onInput,
    this.onChange,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// This attribute is used to specify the name of the control.
  final String? name;

  /// The value of the control.
  final String? value;

  /// Indicates that multiple options can be selected in the list. If it is not specified, then only one option can be selected at a time. When multiple is specified, most browsers will show a scrolling list box instead of a single line dropdown.
  final bool multiple;

  /// Indicating that an option with a non-empty string value must be selected.
  final bool required;

  /// Indicates that the user cannot interact with the control. If this attribute is not specified, the control inherits its setting from the containing element, for example &lt;fieldset&gt;; if there is no containing element with the disabled attribute set, then the control is enabled.
  final bool disabled;

  /// This attribute lets you specify that a form control should have input focus when the page loads. Only one form element in a document can have the autofocus attribute.
  final bool autofocus;

  /// A string providing a hint for a user agent's autocomplete feature.
  final String? autocomplete;

  /// If the control is presented as a scrolling list box (e.g. when multiple is specified), this attribute represents the number of rows in the list that should be visible at one time. Browsers are not required to present a select element as a scrolled list box. The default value is 0.
  final int? size;

  /// Callback for the 'input' event.
  final ValueChanged<List<String>>? onInput;

  /// Callback for the 'change' event.
  final ValueChanged<List<String>>? onChange;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'select',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'name': ?name,
        'value': ?value,
        if (multiple) 'multiple': '',
        if (required) 'required': '',
        if (disabled) 'disabled': '',
        if (autofocus) 'autofocus': '',
        'autocomplete': ?autocomplete,
        'size': ?size?.toString(),
      },
      events: {
        ...?events,
        ..._events(onInput: onInput, onChange: onChange),
      },
      children: children,
    );
  }
}

/// {@template jaspr.html.fieldset}
/// The &lt;fieldset&gt; HTML element is used to group several controls as well as labels (&lt;label&gt;) within a web form.
/// {@endtemplate}
final class fieldset extends StatelessComponent {
  /// {@macro jaspr.html.fieldset}
  const fieldset(
    this.children, {
    this.name,
    this.disabled = false,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The name associated with the group.
  final String? name;

  /// If this Boolean attribute is set, all form controls that are descendants of the &lt;fieldset&gt;, are disabled, meaning they are not editable and won't be submitted along with the &lt;form&gt;. They won't receive any browsing events, like mouse clicks or focus-related events. By default browsers display such controls grayed out. Note that form elements inside the &lt;legend&gt; element won't be disabled.
  final bool disabled;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'fieldset',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {...?attributes, 'name': ?name, if (disabled) 'disabled': ''},
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.textarea}
/// The &lt;textarea&gt; HTML element represents a multi-line plain-text editing control, useful when you want to allow users to enter a sizeable amount of free-form text, for example a comment on a review or feedback form.
/// {@endtemplate}
final class textarea extends StatelessComponent {
  /// {@macro jaspr.html.textarea}
  const textarea(
    this.children, {
    this.autoComplete,
    this.autofocus = false,
    this.cols,
    this.disabled = false,
    this.minLength,
    this.name,
    this.placeholder,
    this.readonly = false,
    this.required = false,
    this.rows,
    this.spellCheck,
    this.wrap,
    this.onInput,
    this.onChange,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Indicates whether the value of the control can be automatically completed by the browser.
  final AutoComplete? autoComplete;

  /// This attribute lets you specify that a form control should have input focus when the page loads. Only one form-associated element in a document can have this attribute specified.
  final bool autofocus;

  /// The visible width of the text control, in average character widths. If it is specified, it must be a positive integer. If it is not specified, the default value is 20.
  final int? cols;

  /// Indicates that the user cannot interact with the control. If this attribute is not specified, the control inherits its setting from the containing element, for example &lt;fieldset&gt;; if there is no containing element when the disabled attribute is set, the control is enabled.
  final bool disabled;

  /// The minimum number of characters (UTF-16 code units) required that the user should enter.
  final int? minLength;

  /// The name of the control
  final String? name;

  /// A hint to the user of what can be entered in the control. Carriage returns or line-feeds within the placeholder text must be treated as line breaks when rendering the hint.
  final String? placeholder;

  /// Indicates that the user cannot modify the value of the control. Unlike the disabled attribute, the readonly attribute does not prevent the user from clicking or selecting in the control. The value of a read-only control is still submitted with the form.
  final bool readonly;

  /// This attribute specifies that the user must fill in a value before submitting a form.
  final bool required;

  /// The number of visible text lines for the control. If it is specified, it must be a positive integer. If it is not specified, the default value is 2.
  final int? rows;

  /// Specifies whether the &lt;textarea&gt; is subject to spell checking by the underlying browser/OS.
  final SpellCheck? spellCheck;

  /// Indicates how the control wraps text. If this attribute is not specified, soft is its default value.
  final TextWrap? wrap;

  /// Callback for the 'input' event.
  final ValueChanged<String>? onInput;

  /// Callback for the 'change' event.
  final ValueChanged<String>? onChange;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'textarea',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'autocomplete': ?autoComplete?.value,
        if (autofocus) 'autofocus': '',
        'cols': ?cols?.toString(),
        if (disabled) 'disabled': '',
        'minlength': ?minLength?.toString(),
        'name': ?name,
        'placeholder': ?placeholder,
        if (readonly) 'readonly': '',
        if (required) 'required': '',
        'rows': ?rows?.toString(),
        'spellcheck': ?spellCheck?.value,
        'wrap': ?wrap?.value,
      },
      events: {
        ...?events,
        ..._events(onInput: onInput, onChange: onChange),
      },
      children: children,
    );
  }
}

/// Specifies whether an element is subject to spell checking by the underlying browser/OS.
enum SpellCheck {
  /// Indicates that the element needs to have its spelling and grammar checked.
  isTrue('true'),

  /// Indicates that the element is to act according to a default behavior, possibly based on the parent element's own spellcheck value.
  isDefault('default'),

  /// Indicates that the element should not be spell checked.
  isFalse('false');

  const SpellCheck(this.value);

  final String value;
}

/// Indicates how the control wraps text.
enum TextWrap {
  /// The browser automatically inserts line breaks (CR+LF) so that each line has no more than the width of the control; the cols attribute must also be specified for this to take effect.
  hard('hard'),

  /// The browser ensures that all line breaks in the value consist of a CR+LF pair, but does not insert any additional line breaks.
  soft('soft');

  const TextWrap(this.value);

  final String value;
}
