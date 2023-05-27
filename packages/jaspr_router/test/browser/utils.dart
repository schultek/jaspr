import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/browser_test.dart';

import '../utils.dart';

extension BrowserTestRouter on BrowserTester {
  RouterState get router {
    return findRouter(binding.rootElement!);
  }
}
