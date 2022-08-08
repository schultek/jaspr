part of jaspr_html;

/// The &lt;details&gt; HTML element creates a disclosure widget in which information is visible only when the widget is toggled into an "open" state. A summary or label must be provided using the &lt;summary&gt; element.
///
/// - [open]: Indicates whether or not the details — that is, the contents of the &lt;details&gt; element — are currently visible.
Component details(List<Component> children, {bool? open, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'details',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (open == true) 'open': '',
    },
    events: events,
    children: children,
  );
}

/// The &lt;dialog&gt; HTML element represents a dialog box or other interactive component, such as a dismissible alert, inspector, or subwindow.
///
/// - [open]: Indicates that the dialog is active and can be interacted with. When the open attribute is not set, the dialog shouldn't be shown to the user.
Component dialog(List<Component> children, {bool? open, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'dialog',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (open == true) 'open': '',
    },
    events: events,
    children: children,
  );
}

/// The &lt;summary&gt; HTML element specifies a summary, caption, or legend for a &lt;details&gt; element's disclosure box. Clicking the &lt;summary&gt; element toggles the state of the parent &lt;details&gt; element open and closed.
Component summary(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'summary',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}
