import '../../foundation/options.dart';
import '../../framework/framework.dart';
import '../markup_render_object.dart';
import 'client_script_adapter.dart';
import 'element_boundary_adapter.dart';
import 'server_component_adapter.dart';

class ClientComponentAdapter extends ElementBoundaryAdapter {
  ClientComponentAdapter(this.adapter, this.target, super.element);

  final ClientScriptAdapter adapter;
  final ClientTarget target;

  late String? data;
  bool isClientBoundary = true;

  @override
  void prepareBoundary(ChildListRange range) {
    isClientBoundary = true;
    element.visitAncestorElements((e) {
      if (adapter.serverElements.containsValue(e)) {
        return false;
      } else if (adapter.clientElements.contains(e)) {
        isClientBoundary = false;
        return false;
      }
      return true;
    });

    if (!isClientBoundary) {
      return;
    }

    data = getData();
  }

  @override
  void applyBoundary(ChildListRange range) {
    if (!isClientBoundary) {
      return;
    }

    range.start.insertNext(ChildNodeData(
        MarkupRenderObject()..updateText('<!--\$${target.name}${data != null ? ' data=$data' : ''}-->', true)));
    range.end.insertPrev(ChildNodeData(MarkupRenderObject()..updateText('<!--/\$${target.name}-->', true)));
  }

  String? getData() {
    var data = target.dataFor(element.component, encode: (o) {
      if (o is Component) {
        return getDataForServerComponent(o, element);
      }
      return o;
    });
    return data;
  }

  String getDataForServerComponent(Component component, Element parent) {
    if (adapter.serverComponents[component] case var s?) {
      return 's\$$s';
    }

    Element? element;

    void findElementFromContext(BuildContext context) {
      context.visitChildElements((e) {
        if (element != null) return;
        if (identical(e.component, component)) {
          element = e;
        } else {
          findElementFromContext(e);
        }
      });
    }

    findElementFromContext(parent);

    if (element == null) {
      adapter.serverComponents[component] = 0;
      return '';
    }

    var s = adapter.serverComponents[component] = adapter.serverElementNum++;
    adapter.serverElements[s] = element;

    binding.addRenderAdapter(ServerComponentAdapter(s, element!));

    return 's\$$s';
  }
}
