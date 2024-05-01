import '../../../server.dart';
import '../../server/child_nodes.dart';

class PlatformHead extends StatelessComponent {
  const PlatformHead(this.children, {super.key});
  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    HeadAdapter.register(context);
    yield* children;
  }
}

class HeadAdapter extends HeadScopeAdapter {
  static HeadAdapter instance = HeadAdapter();

  static bool _registered = false;
  static void register(BuildContext context) {
    var binding = (context.binding as ServerAppBinding);
    if (!_registered) {
      binding.addRenderAdapter(instance);
      _registered = true;
    }

    binding.addRenderAdapter(HeadEntryAdapter(context as Element));
  }

  List<(ChildListRange, int)> entries = [];

  @override
  void applyHead(MarkupRenderObject head) {
    head.children.insertBefore(head.createChildRenderObject()..updateText(r'<!--$-->', true));

    List<MarkupRenderObject> nodes = [];
    Map<String, (int, int)> indices = {};

    String? keyFor(MarkupRenderObject n) {
      if (n.tag == 'title' || n.tag == 'base') {
        return n.tag!;
      } else if (n.tag == 'meta') {
        if (n.attributes?.containsKey('charset') ?? false) {
          return '${n.tag}:charset';
        }
        return '${n.tag}:${n.attributes?['name']}';
      } else {
        return null;
      }
    }

    for (var e in entries) {
      e.$1.remove();
      for (var n in e.$1) {
        var key = keyFor(n);
        if (key == null) {
          nodes.add(n);
          continue;
        }
        var index = indices[key];
        if (index == null) {
          nodes.add(n);
          indices[key] = (nodes.length - 1, e.$2);
        }
        if (index != null && e.$2 >= index.$2) {
          nodes[index.$1] = n;
        }
      }
    }

    for (var n in nodes) {
      head.children.insertBefore(n);
    }

    head.children.insertBefore(head.createChildRenderObject()..updateText(r'<!--/-->', true));
  }
}

class HeadEntryAdapter extends ElementBoundaryAdapter {
  HeadEntryAdapter(super.element);

  @override
  void prepareBoundary(ChildListRange range) {
    HeadAdapter.instance.entries.add((range, element.depth));
  }
}
