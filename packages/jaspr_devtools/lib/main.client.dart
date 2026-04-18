import 'package:jaspr/client.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'main.client.options.dart';
import 'src/components/layout.dart';
import 'src/pages/tree_page.dart';

void main() {
  Jaspr.initializeApp(options: defaultClientOptions);

  runApp(
    Router(
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            Route(
              path: '/',
              builder: (context, state) => const TreePage(),
            ),
          ],
        ),
      ],
    ),
  );
}
