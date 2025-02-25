import '../../framework/framework.dart';
import '../markup_render_object.dart';
import 'head_scope_adapter.dart';

class ClientScriptAdapter extends HeadScopeAdapter {
  ClientScriptAdapter();

  final List<Element> clientElements = [];

  int serverElementNum = 1;
  final Map<Component, int> serverComponents = {};
  final Map<int, Element?> serverElements = {0: null};

  @override
  bool applyHead(MarkupRenderObject head) {
    if (clientElements.isEmpty) {
      return false;
    }
    
    String source;
    if (clientElements.length == 1) {
      var entry = binding.options.clients![clientElements.first.component.runtimeType]!;
      source = '${entry.name}.client';
    } else {
      source = 'main.clients';
    }

    head.children.insertBefore(
      head.createChildRenderObject()
        ..updateElement('script', null, null, null, {'src': '$source.dart.js', 'defer': ''}, null),
    );

    return true;
  }
}
