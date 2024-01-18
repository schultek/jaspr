import '../framework/framework.dart';

class JasprOptions {
  const JasprOptions({this.clientComponents = const {}});

  final Map<Type, ComponentEntry> clientComponents;
}

class ComponentEntry<T extends Component> {
  final String name;
  final Map<String, dynamic>? params;

  const ComponentEntry.client(this.name, {this.params});
}
