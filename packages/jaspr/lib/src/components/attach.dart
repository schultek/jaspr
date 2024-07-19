import '../../jaspr.dart';
import 'attach/attach_client.dart' if (dart.library.io) 'attach/attach_server.dart';

class Attach extends StatelessComponent {
  const Attach.toHtml({this.attributes, super.key}) : target = 'html';
  const Attach.toBody({this.attributes, super.key}) : target = 'body';

  final String target;
  final Map<String, String>? attributes;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PlatformAttach(
      key: key,
      target: target,
      attributes: attributes,
    );
  }
}
