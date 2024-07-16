import '../../../server.dart';
import '../../server/adapters/document_adapter.dart';

class PlatformAttach extends StatelessComponent {
  const PlatformAttach({required this.target, this.attributes, this.events, super.key});

  final String target;
  final Map<String, String>? attributes;
  final EventCallbacks? events;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    AttachAdapter.register(context, this);
  }
}

class AttachAdapter extends RenderAdapter with DocumentStructureMixin {
  static AttachAdapter instance = AttachAdapter();

  static bool _registered = false;
  static void register(BuildContext context, PlatformAttach item) {
    var binding = (context.binding as ServerAppBinding);
    if (!_registered) {
      binding.addRenderAdapter(instance);
      _registered = true;
    }

    instance.items.add(item);
  }

  List<PlatformAttach> items = [];

  @override
  void apply(MarkupRenderObject root) {
    final (html, head, body) = createDocumentStructure(root);

    for (final item in items) {
      if (item.attributes == null) continue;
      if (item.target == 'html') {
        (html.attributes ??= {}).addAll(item.attributes!);
      } else if (item.target == 'head') {
        (head.attributes ??= {}).addAll(item.attributes!);
      } else if (item.target == 'body') {
        (body.attributes ??= {}).addAll(item.attributes!);
      }
    }
  }
}
