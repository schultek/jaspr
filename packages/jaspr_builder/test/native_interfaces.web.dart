export 'dart:html' show window, Window, document, HtmlDocument, Document, Element;

class SomeInterface {
  SomeInterface.named();

  int value = 2;

  void doSomething(String param) {
    print(param);
  }

  static void oha() {}

  static bool isTop = false;
}

Future<String> someTopFunction(SomeInterface interface, {int? v}) {
  return Future.value('ok');
}
