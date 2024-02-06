import '../../jaspr.dart';
import 'head/head_client.dart' if (dart.library.ffi) 'head/head_server.dart';

class Head extends StatelessComponent {
  const Head({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PlatformHead();
  }
}
