import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/browser_test.dart';

extension BrowserRouter on BrowserTester {
  Future<void> navigate(Function(RouterState) navigate, {bool pump = true}) async {
    RouterState? router;
    findRouter(Element element) {
      if (element is StatefulElement && element.state is RouterState) {
        router = element.state as RouterState;
      } else {
        element.visitChildren(findRouter);
      }
    }

    binding.rootElement?.visitChildren(findRouter);
    if (router != null) {
      navigate(router!);
      if (pump) {
        await pumpEventQueue();
      }
    }
  }
}
