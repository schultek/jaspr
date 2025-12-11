import '../../dom/validator.dart';
import '../../framework/framework.dart';
import '../components/client_component_registry.dart';
import '../markup_render_object.dart';
import '../options.dart';
import 'element_boundary_adapter.dart';
import 'server_component_adapter.dart';

class ClientComponentAdapter extends ElementBoundaryAdapter {
  ClientComponentAdapter(this.registry, this.target, super.element);

  final ClientComponentRegistryElement registry;
  final ClientTarget target;

  late String? data;
  bool isClientBoundary = true;

  @override
  void prepareBoundary(ChildListRange range) {
    isClientBoundary = true;
    element.visitAncestorElements((e) {
      if (registry.serverElements.containsValue(e)) {
        return false;
      } else if (registry.clientElements.contains(e)) {
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

    final startMarker = MarkupRenderText(
      '<!--${DomValidator.clientMarkerPrefix}${target.name}${data != null ? ' data=$data' : ''}-->',
      true,
    );
    final endMarker = MarkupRenderText('<!--/${DomValidator.clientMarkerPrefix}${target.name}-->', true);

    range.start.insertNext(ChildNodeData(startMarker));
    range.end.insertPrev(ChildNodeData(endMarker));
  }

  String? getData() {
    final data = target.dataFor(
      element.component,
      encode: (o) {
        if (o is Component) {
          return getDataForServerComponent(o, element);
        }
        return o;
      },
    );
    return data;
  }

  String getDataForServerComponent(Component component, Element parent) {
    if (registry.serverComponents[component] case final s?) {
      return 's${DomValidator.clientMarkerPrefix}$s';
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
      print('Warning: Component parameter not used in build method. This will result in empty html on the client.');

      registry.serverComponents[component] = 0;
      return 's${DomValidator.clientMarkerPrefix}_';
    }

    final s = registry.serverComponents[component] = registry.serverElementNum++;
    registry.serverElements[s] = element;

    binding.addRenderAdapter(ServerComponentAdapter(s, element!));

    return 's${DomValidator.clientMarkerPrefix}$s';
  }
}
