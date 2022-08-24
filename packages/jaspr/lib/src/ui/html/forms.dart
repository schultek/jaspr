part of jaspr_html;

/// The &lt;button&gt; HTML element is an interactive element activated by a user with a mouse, keyboard, finger, voice command, or other assistive technology. Once activated, it then performs a programmable action, such as submitting a form or opening a dialog.
///
/// - [autofocus]: Specifies that the button should have input focus when the page loads. Only one element in a document can have this attribute.
/// - [disabled]: Prevents the user from interacting with the button: it cannot be pressed or focused.
/// - [type]: The default behavior of the button.
Component button(List<Component> children, {bool? autofocus, bool? disabled, ButtonType? type, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
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

/// The &lt;form&gt; HTML element represents a document section containing interactive controls for submitting information.
///
/// - [action]: The URL that processes the form submission. This value can be overridden by a formaction attribute on a &lt;button&gt;, &lt;input type="submit"&gt;, or &lt;input type="image"&gt; element. This attribute is ignored when method="dialog" is set.
/// - [method]: The HTTP method to submit the form with.
///   
///   This value is overridden by formmethod attributes on &lt;button&gt;, &lt;input type="submit"&gt;, or &lt;input type="image"&gt; elements.
/// - [encType]: If the value of the method attribute is post, enctype is the MIME type of the form submission.
/// - [autoComplete]: Indicates whether input elements can by default have their values automatically completed by the browser. autocomplete attributes on form elements override it on &lt;form&gt;.
/// - [name]: The name of the form. The value must not be the empty string, and must be unique among the form elements in the forms collection that it is in, if any.
/// - [noValidate]: Indicates that the form shouldn't be validated when submitted. If this attribute is not set (and therefore the form is validated), it can be overridden by a formnovalidate attribute on a &lt;button&gt;, &lt;input type="submit"&gt;, or &lt;input type="image"&gt; element belonging to the form.
/// - [target]: Indicates where to display the response after submitting the form. In HTML 4, this is the name/keyword for a frame. In HTML5, it is a name/keyword for a browsing context (for example, tab, window, or iframe).
Component form(List<Component> children, {String? action, FormMethod? method, FormEncType? encType, AutoComplete? autoComplete, String? name, bool? noValidate, Target? target, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'form',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (action != null) 'action': action,
      if (method != null) 'method': method.value,
      if (encType != null) 'enctype': encType.value,
      if (autoComplete != null) 'autocomplete': autoComplete.value,
      if (name != null) 'name': name,
      if (noValidate == true) 'novalidate': '',
      if (target != null) 'target': target.value,
    },
    events: events,
    children: children,
  );
}

/// The HTTP method to submit a form with.
enum FormMethod {
  /// The POST method; form data sent as the request body.
  post('post'),
  /// The GET method; form data appended to the action URL with a ? separator. Use this method when the form has no side-effects.
  get('get'),
  /// When the form is inside a &lt;dialog&gt;, closes the dialog and throws a submit event on submission without submitting data or clearing the form.
  dialog('dialog');

  final String value;
  const FormMethod(this.value);
}

/// The MIME type of a form submission.
enum FormEncType {
  /// The default value
  formUrlEncoded('application/x-www-form-urlencoded'),
  /// Use this if the form contains &lt;input&gt; elements with type=file.
  multiPart('multipart/form-data'),
  /// Introduced by HTML5 for debugging purposes.
  text('text/plain');

  final String value;
  const FormEncType(this.value);
}

/// Indicates whether input elements can by default have their values automatically completed by the browser. autocomplete attributes on form elements override it on &lt;form&gt;.
enum AutoComplete {
  /// The browser may not automatically complete entries.
  off('off'),
  /// The browser may automatically complete entries.
  on('on');

  final String value;
  const AutoComplete(this.value);
}

/// The &lt;input&gt; HTML element is used to create interactive controls for web-based forms in order to accept data from the user; a wide variety of types of input data and control widgets are available, depending on the device and user agent. The &lt;input&gt; element is one of the most powerful and complex in all of HTML due to the sheer number of combinations of input types and attributes.
///
/// - [type]: Defines how an &lt;input&gt; works. If this attribute is not specified, the default type adopted is text.
/// - [name]: Name of the form control. Submitted with the form as part of a name/value pair
/// - [value]: The initial value of the control
/// - [disabled]: Indicates that the user should not be able to interact with the input. Disabled inputs are typically rendered with a dimmer color or using some other form of indication that the field is not available for use.
Component input(List<Component> children, {InputType? type, String? name, String? value, bool? disabled, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'input',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (type != null) 'type': type.value,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (disabled == true) 'disabled': '',
    },
    events: events,
    children: children,
  );
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

  final String value;
  const InputType(this.value);
}

/// The &lt;label&gt; HTML element represents a caption for an item in a user interface.
///
/// - [htmlFor]: The value of the for attribute must be a single id for a labelable form-related element in the same document as the &lt;label&gt; element. So, any given label element can be associated with only one form control.
Component label(List<Component> children, {String? htmlFor, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'label',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (htmlFor != null) 'for': htmlFor,
    },
    events: events,
    children: children,
  );
}

/// The &lt;datalist&gt; HTML element contains a set of &lt;option&gt; elements that represent the permissible or recommended options available to choose from within other controls.
Component datalist(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'datalist',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;legend&gt; HTML element represents a caption for the content of its parent &lt;fieldset&gt;.
Component legend(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'legend',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;meter&gt; HTML element represents either a scalar value within a known range or a fractional value.
///
/// - [value]: The current numeric value. This must be between the minimum and maximum values (min attribute and max attribute) if they are specified. If unspecified or malformed, the value is 0. If specified, but not within the range given by the min attribute and max attribute, the value is equal to the nearest end of the range.
/// - [min]: The lower numeric bound of the measured range. This must be less than the maximum value (max attribute), if specified. If unspecified, the minimum value is 0.
/// - [max]: The upper numeric bound of the measured range. This must be greater than the minimum value (min attribute), if specified. If unspecified, the maximum value is 1.
/// - [low]: The upper numeric bound of the low end of the measured range. This must be greater than the minimum value (min attribute), and it also must be less than the high value and maximum value (high attribute and max attribute, respectively), if any are specified. If unspecified, or if less than the minimum value, the low value is equal to the minimum value.
/// - [high]: The lower numeric bound of the high end of the measured range. This must be less than the maximum value (max attribute), and it also must be greater than the low value and minimum value (low attribute and min attribute, respectively), if any are specified. If unspecified, or if greater than the maximum value, the high value is equal to the maximum value.
/// - [optimum]: Indicates the optimal numeric value. It must be within the range (as defined by the min attribute and max attribute). When used with the low attribute and high attribute, it gives an indication where along the range is considered preferable. For example, if it is between the min attribute and the low attribute, then the lower range is considered preferred. The browser may color the meter's bar differently depending on whether the value is less than or equal to the optimum value.
Component meter(List<Component> children, {double? value, double? min, double? max, double? low, double? high, double? optimum, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'meter',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (value != null) 'value': '$value',
      if (min != null) 'min': '$min',
      if (max != null) 'max': '$max',
      if (low != null) 'low': '$low',
      if (high != null) 'high': '$high',
      if (optimum != null) 'optimum': '$optimum',
    },
    events: events,
    children: children,
  );
}

/// The &lt;progress&gt; HTML element displays an indicator showing the completion progress of a task, typically displayed as a progress bar.
///
/// - [value]: This attribute specifies how much of the task that has been completed. It must be a valid floating point number between 0 and max, or between 0 and 1 if max is omitted. If there is no value attribute, the progress bar is indeterminate; this indicates that an activity is ongoing with no indication of how long it is expected to take.
/// - [max]: This attribute describes how much work the task indicated by the progress element requires. The max attribute, if present, must have a value greater than 0 and be a valid floating point number. The default value is 1.
Component progress(List<Component> children, {double? value, double? max, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'progress',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (value != null) 'value': '$value',
      if (max != null) 'max': '$max',
    },
    events: events,
    children: children,
  );
}

/// The &lt;optgroup&gt; HTML element creates a grouping of options within a &lt;select&gt; element.
///
/// - [label]: The name of the group of options, which the browser can use when labeling the options in the user interface.
/// - [disabled]: If this attribute is set, none of the items in this option group is selectable. Often browsers grey out such control and it won't receive any browsing events, like mouse clicks or focus-related ones.
Component optgroup(List<Component> children, {required String label, bool? disabled, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'optgroup',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      'label': label,
      if (disabled == true) 'disabled': '',
    },
    events: events,
    children: children,
  );
}

/// The &lt;option&gt; HTML element is used to define an item contained in a &lt;select&gt;, an &lt;optgroup&gt;, or a &lt;datalist&gt; element. As such, &lt;option&gt; can represent menu items in popups and other lists of items in an HTML document.
///
/// - [label]: This attribute is text for the label indicating the meaning of the option. If the label attribute isn't defined, its value is that of the element text content.
/// - [value]: The content of this attribute represents the value to be submitted with the form, should this option be selected. If this attribute is omitted, the value is taken from the text content of the option element.
/// - [selected]: Indicates that the option is initially selected. If the &lt;option&gt; element is the descendant of a &lt;select&gt; element whose multiple attribute is not set, only one single &lt;option&gt; of this &lt;select&gt; element may have the selected attribute.
/// - [disabled]: If this attribute is set, this option is not checkable. Often browsers grey out such control and it won't receive any browsing event, like mouse clicks or focus-related ones. If this attribute is not set, the element can still be disabled if one of its ancestors is a disabled &lt;optgroup&gt; element.
Component option(List<Component> children, {String? label, String? value, bool? selected, bool? disabled, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'option',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (label != null) 'label': label,
      if (value != null) 'value': value,
      if (selected == true) 'selected': '',
      if (disabled == true) 'disabled': '',
    },
    events: events,
    children: children,
  );
}

/// The <select> HTML element represents a control that provides a menu of options.
///
/// - [name]: This attribute is used to specify the name of the control.
/// - [multiple]: Indicates that multiple options can be selected in the list. If it is not specified, then only one option can be selected at a time. When multiple is specified, most browsers will show a scrolling list box instead of a single line dropdown.
/// - [required]: Indicating that an option with a non-empty string value must be selected.
/// - [disabled]: Indicates that the user cannot interact with the control. If this attribute is not specified, the control inherits its setting from the containing element, for example <fieldset>; if there is no containing element with the disabled attribute set, then the control is enabled.
/// - [autofocus]: This attribute lets you specify that a form control should have input focus when the page loads. Only one form element in a document can have the autofocus attribute.
/// - [autocomplete]: A string providing a hint for a user agent's autocomplete feature.
/// - [size]: If the control is presented as a scrolling list box (e.g. when multiple is specified), this attribute represents the number of rows in the list that should be visible at one time. Browsers are not required to present a select element as a scrolled list box. The default value is 0.
Component select(List<Component> children, {String? name, bool? multiple, bool? required, bool? disabled, bool? autofocus, String? autocomplete, int? size, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'select',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (name != null) 'name': name,
      if (multiple == true) 'multiple': '',
      if (required == true) 'required': '',
      if (disabled == true) 'disabled': '',
      if (autofocus == true) 'autofocus': '',
      if (autocomplete != null) 'autocomplete': autocomplete,
      if (size != null) 'size': '$size',
    },
    events: events,
    children: children,
  );
}

/// The &lt;textarea&gt; HTML element represents a multi-line plain-text editing control, useful when you want to allow users to enter a sizeable amount of free-form text, for example a comment on a review or feedback form.
///
/// - [autoComplete]: Indicates whether the value of the control can be automatically completed by the browser.
/// - [autofocus]: This attribute lets you specify that a form control should have input focus when the page loads. Only one form-associated element in a document can have this attribute specified.
/// - [cols]: The visible width of the text control, in average character widths. If it is specified, it must be a positive integer. If it is not specified, the default value is 20.
/// - [disabled]: Indicates that the user cannot interact with the control. If this attribute is not specified, the control inherits its setting from the containing element, for example &lt;fieldset&gt;; if there is no containing element when the disabled attribute is set, the control is enabled.
/// - [minLength]: The minimum number of characters (UTF-16 code units) required that the user should enter.
/// - [name]: The name of the control
/// - [placeholder]: A hint to the user of what can be entered in the control. Carriage returns or line-feeds within the placeholder text must be treated as line breaks when rendering the hint.
/// - [readonly]: Indicates that the user cannot modify the value of the control. Unlike the disabled attribute, the readonly attribute does not prevent the user from clicking or selecting in the control. The value of a read-only control is still submitted with the form.
/// - [required]: This attribute specifies that the user must fill in a value before submitting a form.
/// - [rows]: The number of visible text lines for the control. If it is specified, it must be a positive integer. If it is not specified, the default value is 2.
/// - [spellCheck]: Specifies whether the &lt;textarea&gt; is subject to spell checking by the underlying browser/OS.
/// - [wrap]: Indicates how the control wraps text. If this attribute is not specified, soft is its default value.
Component textarea(List<Component> children, {AutoComplete? autoComplete, bool? autofocus, int? cols, bool? disabled, int? minLength, String? name, String? placeholder, bool? readonly, bool? required, int? rows, SpellCheck? spellCheck, TextWrap? wrap, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'textarea',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (autoComplete != null) 'autocomplete': autoComplete.value,
      if (autofocus == true) 'autofocus': '',
      if (cols != null) 'cols': '$cols',
      if (disabled == true) 'disabled': '',
      if (minLength != null) 'minlength': '$minLength',
      if (name != null) 'name': name,
      if (placeholder != null) 'placeholder': placeholder,
      if (readonly == true) 'readonly': '',
      if (required == true) 'required': '',
      if (rows != null) 'rows': '$rows',
      if (spellCheck != null) 'spellcheck': spellCheck.value,
      if (wrap != null) 'wrap': wrap.value,
    },
    events: events,
    children: children,
  );
}

/// Specifies whether an element is subject to spell checking by the underlying browser/OS.
enum SpellCheck {
  /// Indicates that the element needs to have its spelling and grammar checked.
  isTrue('true'),
  /// Indicates that the element is to act according to a default behavior, possibly based on the parent element's own spellcheck value.
  isDefault('default'),
  /// Indicates that the element should not be spell checked.
  isFalse('false');

  final String value;
  const SpellCheck(this.value);
}

/// Indicates how the control wraps text.
enum TextWrap {
  /// The browser automatically inserts line breaks (CR+LF) so that each line has no more than the width of the control; the cols attribute must also be specified for this to take effect.
  hard('hard'),
  /// The browser ensures that all line breaks in the value consist of a CR+LF pair, but does not insert any additional line breaks.
  soft('soft');

  final String value;
  const TextWrap(this.value);
}
