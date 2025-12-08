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
/// independent of the actual position of that component in the DOM tree. It
/// allows client components to share a root subtree, which can be useful for
/// sharing state by wrapping this component with one or more [InheritedComponent]s.
///
/// Beware that wrapping this component with components that render DOM objects
/// may prevent @client components to be properly hydrated.
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

  @override
  void didMount() {
    final parent = parentRenderObjectElement!.renderObject;
    final nodes = parent is HydratableDomRenderObject ? parent.toHydrate : <web.Node>[];
    final anchors = extractAnchors(nodes: nodes);

    for (final anchor in anchors) {
      if (anchor.builder is ClientBuilder) {
        this.anchors.add(anchor);
        slots.add(anchor.createSlot());
      } else {
        anchor
            .resolve()
            .then((b) {
              if (mounted) {
                this.anchors.add(anchor);
                slots.add(anchor.createSlot());
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
