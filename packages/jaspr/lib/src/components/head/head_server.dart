import '../../../server.dart';
import '../../server/child_nodes.dart';
import '../../server/markup_render_object.dart';

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

  List<ChildListRange> entries = [];

  @override
  void applyHead(MarkupRenderObject head) {
    head.children.insertBefore(head.createChildRenderObject()..updateText(r'<!--$-->', true));
    for (var e in entries) {
      head.children.insertNodeBefore(e);
    }
    head.children.insertBefore(head.createChildRenderObject()..updateText(r'<!--/-->', true));
  }
}

class HeadEntryAdapter extends ElementBoundaryAdapter {
  HeadEntryAdapter(super.element);

  @override
  void prepareBoundary(ChildListRange range) {
    HeadAdapter.instance.entries.add(range);
  }
}
