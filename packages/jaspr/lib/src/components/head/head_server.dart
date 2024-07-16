import '../../../server.dart';
import '../../server/child_nodes.dart';

class PlatformHead extends StatelessComponent {
  const PlatformHead({required this.children, super.key});

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
    final binding = context.binding as ServerAppBinding;
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

    final List<MarkupRenderObject> nodes = [];
    final Map<String, (int, int)> indices = {};

    String? keyFor(MarkupRenderObject n) {
      return switch (n) {
        MarkupRenderObject(id: final String id) when id.isNotEmpty => id,
        MarkupRenderObject(tag: 'title' || 'base') => '__${n.tag}',
        MarkupRenderObject(tag: 'meta', attributes: {'name': final String name}) => '__meta:$name',
        _ => null,
      };
    }

    for (final e in entries) {
      e.$1.remove();
      for (final n in e.$1) {
        final key = keyFor(n);
        if (key == null) {
          nodes.add(n);
          continue;
        }
        final index = indices[key];
        if (index == null) {
          nodes.add(n);
          indices[key] = (nodes.length - 1, e.$2);
        }
        if (index != null && e.$2 >= index.$2) {
          nodes[index.$1] = n;
        }
      }
    }

    for (final n in nodes) {
      head.children.insertBefore(n);
    }

    head.children.insertBefore(head.createChildRenderObject()..updateText('<!--/-->', true));
  }
}

class HeadEntryAdapter extends ElementBoundaryAdapter {
  HeadEntryAdapter(super.element);

  @override
  void prepareBoundary(ChildListRange range) {
    HeadAdapter.instance.entries.add((range, element.depth));
  }
}
