part of 'framework.dart';

/// A utility component that renders its [children] without any wrapper element.
///
/// This is meant to be used in places where you want to render multiple components,
/// but only a single component is allowed by the API.
class Fragment extends Component {
  const Fragment({required this.children, super.key});

  final List<Component> children;

  @override
  Element createElement() => FragmentElement(this);
}

class FragmentElement extends MultiChildRenderObjectElement {
  FragmentElement(Fragment super.component);

  @override
  List<Component> buildChildren() => (component as Fragment).children;

  @override
  RenderObject createRenderObject() {
    final renderObject = _parentRenderObjectElement!.renderObject.createChildRenderFragment();
    assert(renderObject.parent == _parentRenderObjectElement!.renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(RenderFragment fragment) {}
}
