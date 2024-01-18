import '../framework/framework.dart';

class JasprOptions {
  const JasprOptions({this.clientComponents = const {}});

  final Map<Type, ComponentEntry> clientComponents;
}

class ComponentEntry<T extends Component> {
  final String name;
  final Map<String, dynamic> Function(T component)? params;

  const ComponentEntry.client(this.name, {this.params});

  Map<String, dynamic> encode(T component) {
    return {'name': name, if (params != null) 'params': params!(component)};
  }
}
