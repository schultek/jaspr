import 'package:jaspr/html.dart';
import 'package:jaspr/server.dart' hide Response;
import 'package:vercel_edge/vercel_edge.dart';

import 'counter.dart';

void main() {
  VercelEdge(fetch: (request) async {
    return Response(
      headers: Headers({'Content-Type': 'text/html'}),
      await renderComponent(useIsolates: false, Document(
        body: Builder(builder: (context) sync* {
          yield p([text('Hello World')]);
          yield ul([
            li([text('IP Adress: ${request.vc.ipAddress}')]),
            li([text('City: ${request.vc.city}')]),
            li([text('Country: ${request.vc.country}')]),
            li([text('Region: ${request.vc.region}')]),
            li([text('Country Region: ${request.vc.countryRegion}')]),
            li([text('Latitude: ${request.vc.latitude}')]),
            li([text('Longitude: ${request.vc.longitude}')]),
          ]);
          yield div(id: 'counter', [Counter()]);
        }),
      )),
    );
  });
}
