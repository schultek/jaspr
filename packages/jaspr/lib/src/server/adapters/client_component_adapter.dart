import '../../dom/validator.dart';
import '../../framework/framework.dart';
import '../components/client_component_registry.dart';
import '../markup_render_object.dart';
import '../options.dart';
import 'element_boundary_adapter.dart';
import 'server_component_adapter.dart';

class ClientComponentAdapter extends ElementBoundaryAdapter {
  ClientComponentAdapter(this.registry, this.target, super.element) : super(priority: 1000);

  final ClientComponentRegistryElement registry;
  final ClientTarget target;

  bool _isClientBoundary = true;
  late String? data;

  @override
  void prepareBoundary(ChildListRange range) {
    // If a client component is itself a server component, it is a client boundary.
    if (registry.serverElements.containsKey(element)) {
      _isClientBoundary = true;
    } else {
      element.visitAncestorElements((e) {
        // If a client component is nested in a server component it is also a client boundary.
        if (registry.serverElements.containsKey(e)) {
          _isClientBoundary = true;
          return false;
        }
        // If a client component is nested in a client component (with no server component in-between)
        // it is not a client boundary.
        if (registry.clientElements.containsKey(e)) {
          _isClientBoundary = false;
          return false;
        }
        return true;
      });
    }

    if (!_isClientBoundary) {
      return;
    }

    data = getData();
  }

  @override
  void applyBoundary(ChildListRange range) {
    if (!_isClientBoundary) {
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
    final key = (parent, component);
    if (registry.serverComponents[key] case final s?) {
      return 's${DomValidator.clientMarkerPrefix}$s';
    }

    final elements = <Element>[];

    void findElementsFromContext(BuildContext context) {
      context.visitChildElements((e) {
        if (identical(e.component, component)) {
          elements.add(e);
        }
        findElementsFromContext(e);
      });
    }

    findElementsFromContext(parent);

    if (elements.isEmpty) {
      print('Warning: Component parameter not used in build method. This will result in empty html on the client.');
      registry.serverComponents[key] = 0;
      return 's${DomValidator.clientMarkerPrefix}_';
    }

    final s = registry.serverComponents[key] = registry.serverElementNum++;

    for (final element in elements) {
      registry.serverElements[element] = s;
      binding.addRenderAdapter(ServerComponentAdapter(s, element));
    }

    return 's${DomValidator.clientMarkerPrefix}$s';
  }
}
