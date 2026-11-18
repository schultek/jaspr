import 'package:universal_web/js_interop.dart';

// For type checks against DOM types we're looking up the constructor
// functions of those DOM types *once* and cache them.
//
// That allows for much faster type checking via
// `JSObject.instanceof(constructor)` as it avoids re-resolving the names
// repeatedly.
//
// See also https://github.com/dart-lang/sdk/issues/60344
extension DomTypeTests on JSAny? {
  bool get isElement => this == null ? false : instanceof(_cachedElementConstructor);
  bool get isHtmlInputElement => this == null ? false : instanceof(_cachedHtmlInputElementConstructor);
  bool get isHtmlAnchorElement => this == null ? false : instanceof(_cachedHtmlAnchorElementConstructor);
  bool get isHtmlSelectElement => this == null ? false : instanceof(_cachedHtmlSelectElementConstructor);
  bool get isTextAreaElement => this == null ? false : instanceof(_cachedHtmlTextAreaElementConstructor);
  bool get isHtmlOptionElement => this == null ? false : instanceof(_cachedHtmlOptionElementConstructor);
  bool get isHtmlDialogElement => this == null ? false : instanceof(_cachedHtmlDialogElementConstructor);
  bool get isHtmlDetailsElement => this == null ? false : instanceof(_cachedHtmlDetailsElementConstructor);
  bool get isText => this == null ? false : instanceof(_cachedTextConstructor);
  bool get isComment => this == null ? false : instanceof(_cachedCommentConstructor);
  bool get isDocumentFragment => this == null ? false : instanceof(_cachedDocumentFragmentConstructor);
}

final _cachedElementConstructor = _elementConstructor;
final _cachedHtmlInputElementConstructor = _htmlInputElementConstructor;
final _cachedHtmlAnchorElementConstructor = _htmlAnchorElementConstructor;
final _cachedHtmlSelectElementConstructor = _htmlSelectElementConstructor;
final _cachedHtmlTextAreaElementConstructor = _htmlTextAreaElementConstructor;
final _cachedHtmlOptionElementConstructor = _htmlOptionElementConstructor;
final _cachedHtmlDialogElementConstructor = _htmlDialogElementConstructor;
final _cachedHtmlDetailsElementConstructor = _htmlDetailsElementConstructor;
final _cachedTextConstructor = _textConstructor;
final _cachedCommentConstructor = _commentConstructor;
final _cachedDocumentFragmentConstructor = _documentFragmentConstructor;

@JS('Element')
external JSFunction get _elementConstructor;
@JS('HTMLInputElement')
external JSFunction get _htmlInputElementConstructor;
@JS('HTMLAnchorElement')
external JSFunction get _htmlAnchorElementConstructor;
@JS('HTMLSelectElement')
external JSFunction get _htmlSelectElementConstructor;
@JS('HTMLTextAreaElement')
external JSFunction get _htmlTextAreaElementConstructor;
@JS('HTMLOptionElement')
external JSFunction get _htmlOptionElementConstructor;
@JS('HTMLDialogElement')
external JSFunction get _htmlDialogElementConstructor;
@JS('HTMLDetailsElement')
external JSFunction get _htmlDetailsElementConstructor;
@JS('Text')
external JSFunction get _textConstructor;
@JS('Comment')
external JSFunction get _commentConstructor;
@JS('DocumentFragment')
external JSFunction get _documentFragmentConstructor;
