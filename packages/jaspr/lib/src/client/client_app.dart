import 'dart:async';

import 'package:universal_web/web.dart' as web;

import '../framework/framework.dart';
import 'component_anchors.dart';
import 'dom_render_object.dart';
import 'options.dart';
import 'slotted_child_view.dart';

/// Locates and initializes @client components during hydration.
///
/// Each @client component will be mounted as a direct child of this component,
/// independent of the actual position of that component in the DOM tree.
/// It allows client components to share a root subtree, which can be useful for
/// sharing state by wrapping this component with one or more [InheritedComponent]s.
///
/// Beware that wrapping this component with components that render DOM objects
/// might prevent @client components to be properly hydrated.
///
/// Requires [Jaspr.initializeApp] to be called with the generated [ClientOptions]
/// before being used.
final class ClientApp extends Component {
  const ClientApp();

  @override
  Element createElement() => _ClientAppElement(this);
}

class _ClientAppElement extends BuildableElement {
  _ClientAppElement(ClientApp super.component);

  final List<ClientComponentAnchor> anchors = [];
  final List<ChildSlot> slots = [];

  bool mounted = true;

  FutureOr<ClientBuilder> getClientByName(String name) {
    final clients = Jaspr.options.clients;
    assert(clients.containsKey(name), "No client component registered with name '$name'.");
    return clients[name]!.loadedBuilder;
  }

  @override
  void didMount() {
    final parent = parentRenderObjectElement!.renderObject;
    final nodes = parent is HydratableDomRenderObject ? parent.toHydrate : <web.Node>[];
    final anchors = extractClientAnchors(getClientByName, nodes: nodes);

    for (final anchor in anchors) {
      if (anchor.builder is ClientBuilder) {
        this.anchors.add(anchor);
        slots.add(createSlotForAnchor(anchor));
      } else {
        anchor
            .resolve()
            .then((b) {
              if (mounted) {
                this.anchors.add(anchor);
                slots.add(createSlotForAnchor(anchor));
                markNeedsBuild();
              }
            })
            .onError((error, stackTrace) {
              print("Error loading client component '${anchor.name}': $error");
            });
      }
    }
    super.didMount();
  }

  ChildSlot createSlotForAnchor(ClientComponentAnchor anchor) {
    return _AnchorChildSlot(
      start: anchor.startNode,
      end: anchor.endNode,
      child: anchor.build(),
    );
  }

  @override
  Component build() {
    return SlottedChildView(slots: slots);
  }

  @override
  void unmount() {
    mounted = false;
    super.unmount();
  }
}

class _AnchorChildSlot extends ChildSlot {
  _AnchorChildSlot({required this.start, required this.end, required this.child});

  final web.Node start;
  final web.Node end;
  @override
  final Component child;

  @override
  ChildSlotRenderObject createRenderObject(SlottedDomRenderObject parent) {
    return ChildSlotRenderObject.between(parent, start, end);
  }

  @override
  bool canUpdate(ChildSlot oldComponent) {
    return oldComponent is _AnchorChildSlot && oldComponent.start == start && oldComponent.end == end;
  }
}
