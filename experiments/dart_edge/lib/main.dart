import 'package:jaspr/server.dart' hide Response;
import './app.dart';

import 'package:vercel_edge/vercel_edge.dart';

void main() {
  VercelEdge(fetch: (request) async {

    return Response(
      await renderComponent(useIsolates: false, Document.app(
        body: App(props: request.vc),
      )),
      headers: Headers({'Content-Type': 'text/html'}),
    );
  });
}
