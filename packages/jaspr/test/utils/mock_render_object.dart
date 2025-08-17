import 'package:jaspr/src/framework/framework.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRenderObjectBinding extends TestComponentsBinding {
  MockRenderObjectBinding(super.currentUrl, super.isClient) {
    registerFallbackValue(MockRenderObject());
  }

  final MockRenderObject root = MockRenderObject();

  @override
  RenderObject createRootRenderObject() {
    return root;
  }
}

class MockRenderObject extends Mock implements RenderObject {}

final mockChildren = Expando<List<MockRenderObject>>();

extension MockChildren on MockRenderObject {
  List<MockRenderObject> get children => mockChildren[this] ??= [];

  MockRenderObject get c1 => children[0];
  MockRenderObject get c2 => children[1];
}

void autoMockChildren(MockRenderObject renderObject) {
  when(() => renderObject.createChildRenderObject()).thenAnswer((_) {
    final child = MockRenderObject();
    when(() => child.parent).thenReturn(renderObject);
    autoMockChildren(child);
    return child;
  });
  when(() => renderObject.attach(any(), after: any(named: 'after'))).thenAnswer((invocation) {
    final child = invocation.positionalArguments[0] as MockRenderObject;
    final after = invocation.namedArguments[#after] as MockRenderObject?;
    final children = mockChildren[renderObject] ??= [];
    if (after != null) {
      children.insert(children.indexOf(after) + 1, child);
    } else {
      children.insert(0, child);
    }
    when(() => child.parent).thenReturn(renderObject);
  });
  when(() => renderObject.remove(any())).thenAnswer((invocation) {
    final child = invocation.positionalArguments[0] as MockRenderObject;
    mockChildren[renderObject]?.remove(child);
    when(() => child.parent).thenReturn(null);
  });
}

void verifyNoMoreRenderInteractions(MockRenderObject root) {
  verifyNoMoreInteractions(root);
  for (var child in root.children) {
    verifyNoMoreRenderInteractions(child);
  }
}
