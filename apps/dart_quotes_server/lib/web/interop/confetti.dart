import 'dart:js_interop';

extension type JSConfetti._(JSObject _) {
  external JSConfetti();

  static JSConfetti instance = JSConfetti();

  external void addConfetti([ConfettiOptions? options]);

  void show({List<String>? emojis}) {
    addConfetti(ConfettiOptions(emojis: emojis.jsify()));
  }
}

extension type ConfettiOptions._(JSObject o) implements JSObject {
  external ConfettiOptions({JSAny? emojis});
}
