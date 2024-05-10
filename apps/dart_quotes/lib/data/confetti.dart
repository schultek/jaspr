import 'dart:js_interop';

void showConfetti({List<String>? emojis}) {
  JSConfetti.instance.addConfetti(ConfettiOptions(emojis: emojis.jsify()));
}

extension type JSConfetti._(JSObject _) {
  external JSConfetti();

  static JSConfetti instance = JSConfetti();

  external void addConfetti([ConfettiOptions? options]);
}

extension type ConfettiOptions._(JSObject o) implements JSObject {
  external ConfettiOptions({JSAny? emojis});
}
