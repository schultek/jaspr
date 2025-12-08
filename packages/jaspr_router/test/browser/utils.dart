import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/client_test.dart';

import '../utils.dart';

extension BrowserTestRouter on ClientTester {
  RouterState get router {
    return findRouter(binding.rootElement!);
  }
}
