import 'package:jaspr/jaspr.dart';

import '../../adapters/html.dart' hide Element;

class DomNodeReader extends StatefulComponent {
  const DomNodeReader({required this.onNode, required this.child, super.key});

  final void Function(ElementOrStubbed node) onNode;
  final Component child;

  @override
  State<DomNodeReader> createState() => _NodeReaderState();
}

class _NodeReaderState extends State<DomNodeReader> {
  @override
  Component build(BuildContext context) {
    if (kIsWeb) {
      context.binding.addPostFrameCallback(() {
        void handleChild(Element element) {
          if (element is! RenderObjectElement) {
            return element.visitChildElements(handleChild);
          }
          var node = (element).renderObject as dynamic; // DomRenderObject
          component.onNode(node.node as ElementOrStubbed);
        }

        context.visitChildElements(handleChild);
      });
    }

    return component.child;
  }
}
