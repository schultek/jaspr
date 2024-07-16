import '../../jaspr.dart';
import 'attach/attach_client.dart' if (dart.library.io) 'attach/attach_server.dart';

class Attach extends StatelessComponent {
  const Attach.toHtml({this.attributes, this.events, super.key}) : target = 'html';
  const Attach.toHead({this.attributes, this.events, super.key}) : target = 'head';
  const Attach.toBody({this.attributes, this.events, super.key}) : target = 'body';

  final String target;
  final Map<String, String>? attributes;
  final EventCallbacks? events;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PlatformAttach(
      key: key,
      target: target,
      attributes: attributes,
      events: events,
    );
  }
}
