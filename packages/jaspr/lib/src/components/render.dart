import '../framework/framework.dart';

/// Component that has a custom render function
abstract class CustomRenderComponent extends Component {
  const CustomRenderComponent({super.key});

  void render(DomBuilder b);

  @override
  Element createElement() => CustomRenderElement(this);
}

/// Element that lets the component perform the rendering
class CustomRenderElement extends SingleChildElement {
  CustomRenderElement(super.component);

  @override
  CustomRenderComponent get component => super.component as CustomRenderComponent;

  @override
  Component? build() => null;

  @override
  void render(DomBuilder b) {
    super.render(b);
    component.render(b);
  }
}

/// Component that skips rendering for a number of child nodes
class SkipChildComponent extends CustomRenderComponent {
  final int n;

  SkipChildComponent({this.n = 1, super.key});

  @override
  void render(DomBuilder b) {
    try {
      for (var i = 0; i < n; i++) {
        b.skipNode();
      }
    } on AssertionError {
      // ignore
    }
  }
}

/// Component that skips rendering for all child nodes
class SkipRemainingChildrenComponent extends CustomRenderComponent {
  @override
  void render(DomBuilder b) {
    try {
      b.skipRemainingNodes();
    } on AssertionError {
      // ignore
    }
  }
}
