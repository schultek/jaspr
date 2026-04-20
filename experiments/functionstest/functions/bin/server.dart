import 'package:firebase_functions/firebase_functions.dart';
import 'package:functionstest/main.server.dart';
import 'package:jaspr/server.dart';

void main(List<String> args) {
  fireUp(args, (firebase) {
    // Set maxInstances to control costs during unexpected traffic spikes.
    firebase.https.onRequest(
      name: 'renderApp',
      options: const HttpsOptions(
        cors: Cors(['*']),
        maxInstances: Instances(10),
        region: DeployOption(SupportedRegion.europeWest1),
      ),
      (request) async {
        print('Request: ${request.method} ${request.url} ${request.handlerPath} ${request.headers}');
        final response = await renderComponent(app, request: request);
        return Response(response.statusCode, body: response.body, headers: response.headers);
      },
    );
  });
}
