abstract class Event {
  Node get target;

  void preventDefault();
}

abstract class HTMLInputElement implements Node {
  bool get checked;

  num get valueAsNumber;

  DateTime get valueAsDate;

  Object get files;

  Object get value;

  Object get type;
}

abstract class HTMLTextAreaElement implements Node {
  get value;
}

abstract class HTMLSelectElement implements Node {
  HTMLCollection get selectedOptions;
}

abstract class HTMLOptionElement implements Node {
  Object get value;
}

abstract class HTMLCollection {
  int get length;
  Node? item(int index);
}

abstract class Node {}

extension JSAnyUtilityExtension on dynamic {
  bool instanceOfString(String constructorName) => true;
}
