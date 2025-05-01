import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_og/jaspr_og.dart';
import 'package:pub_api_client/pub_api_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router =
    Router()
      ..get('/packages/<package>.png', _packageImageHandler)
      ..get('/packages/<package>', _packageHandler);

Future<Response> _packageHandler(Request request) async {
  final name = request.params['package']!;
  final client = PubClient();
  try {
    final package = await client.packageInfo(name);

    Jaspr.initializeApp(useIsolates: false);
    final response = await renderApp(
      Document(
        title: package.name,
        head: [
          meta(attributes: {'http-equiv': 'refresh', 'content': '1; url=https://pub.dev/packages/$name'}),
          meta(name: 'description', content: package.description),
          meta(attributes: {'property': 'og:type', 'content': 'website'}),
          meta(name: 'twitter:card', content: 'summary_large_image'),
          meta(name: 'twitter:site', content: '@dart_lang'),
          meta(attributes: {'property': 'og:title', 'content': package.name}),
          meta(attributes: {'property': 'og:description', 'content': package.description}),
          meta(attributes: {'property': 'og:url', 'content': 'https://pub.dev/packages/$name'}),
          meta(attributes: {'property': 'og:image', 'content': 'https://pub.schultek.dev/packages/$name.png'}),
        ],
        body: Fragment(children: []),
      ),
    );
    return Response(
      response.statusCode,
      body: switch (response.body) {
        ResponseBodyString(:final content) => content,
        ResponseBodyBytes(:final bytes) => bytes,
      },
      headers: {...response.headers, 'Cache-Control': 'public, max-age=3600, s-maxage=86400'},
    );
  } catch (e) {
    print(e);
    return Response.notFound('Package not found');
  } finally {
    client.close();
  }
}

Component txt(String t, Map<String, String> attributes, [List<Component> children = const []]) {
  return DomComponent(tag: 'text', attributes: attributes, children: [text(t), ...children]);
}

Component wrap(String t, int length, Map<String, String> attributes) {
  final lines = <String>[];
  final words = t.split(' ');
  var currentLine = '';
  for (final word in words) {
    if (currentLine.length + word.length + 1 > length) {
      lines.add(currentLine);
      currentLine = '';
    }
    currentLine += (currentLine.isEmpty ? '' : ' ') + word;
  }
  if (currentLine.isNotEmpty) {
    lines.add(currentLine);
  }
  return Fragment(
    children: [
      for (final (index, line) in lines.indexed)
        txt(line, {...attributes, 'y': '${(int.tryParse(attributes['y'] ?? '0') ?? 0) + index * 50}'}),
    ],
  );
}

Component g(List<Component> children, [Map<String, String>? attributes]) {
  return DomComponent(tag: 'g', attributes: attributes, children: children);
}

Component metric(num? value, String label, {int x = 0, int y = 0}) {
  if (value == null) {
    return Fragment(children: []);
  }
  return g([
    txt(
      switch (value) {
        >= 1000000 => '${(value / 1000000).toStringAsFixed(2)}M',
        >= 100000 => '${(value / 100000).toStringAsFixed(0)}K',
        >= 10000 => '${(value / 10000).toStringAsFixed(1)}K',
        >= 1000 => '${(value / 1000).toStringAsFixed(1)}K',
        _ => value.toString(),
      },
      {'x': '$x', 'y': '$y', 'class': 'metric-value'},
    ),
    txt(label, {'x': '$x', 'y': '${y + 40}', 'class': 'metric-label'}),
  ]);
}

Future<Response> _packageImageHandler(Request request) async {
  final name = request.params['package']!;

  final client = PubClient();
  try {
    final package = await client.packageInfo(name);
    final score = await client.packageScore(name);
    final version = await client.packageVersionInfo(name, package.version);

    final ago = DateTime.now().difference(version.published).inDays;
    final agoString =
        ago == 0
            ? 'today'
            : ago == 1
            ? 'yesterday'
            : ago < 30
            ? '$ago days ago'
            : ago / 30 < 2
            ? 'a month ago'
            : '${(ago / 30).round()} months ago';

    final output = await renderSvg(
      svg(width: 1200.px, height: 630.px, [
        Style(
          styles: [
            css('*').styles(
              fontFamily: FontFamily.list([
                FontFamily('Open Sans'),
                FontFamilies.uiSansSerif,
                FontFamilies.systemUi,
                FontFamily('DejaVu Sans'),
                FontFamilies.sansSerif,
              ]),
            ),
            css('.title').styles(fontSize: 65.px, fontWeight: FontWeight.bold, raw: {'fill': Color('#222').value}),
            css('.version').styles(fontSize: 60.px, fontWeight: FontWeight.normal, raw: {'fill': Color('#222').value}),
            css('.details').styles(fontSize: 30.px, fontWeight: FontWeight.normal, raw: {'fill': Color('#444').value}),
            css(
              '.description',
            ).styles(fontSize: 30.px, fontWeight: FontWeight.normal, raw: {'fill': Color('#444').value}),
            css(
              '.metric-value',
            ).styles(fontSize: 40.px, fontWeight: FontWeight.bold, raw: {'fill': Color('#222').value}),
            css(
              '.metric-label',
            ).styles(fontSize: 25.px, fontWeight: FontWeight.normal, raw: {'fill': Color('#444').value}),
          ],
        ),
        g([
          rect(x: "0", y: "0", width: "100%", height: "100%", fill: Colors.white, []),
          txt(
            package.name,
            {'x': '100', 'y': '160', 'class': 'title'},
            [
              DomComponent(tag: 'tspan', classes: 'version', children: [text(package.version)]),
            ],
          ),
          txt('Published $agoString', {'x': '100', 'y': '210', 'class': 'details'}),
          wrap(package.description, 45, {'x': '100', 'y': '280', 'class': 'description'}),
          DomComponent(
            tag: 'image',
            attributes: {'x': '900', 'y': '80', 'width': '200', 'height': 'auto', 'href': 'assets/dart.png'},
            children: [],
          ),

          metric(score.likeCount, 'Likes', x: 100, y: 510),
          metric(score.grantedPoints, 'Points', x: 270, y: 510),
          metric(score.downloadCount30Days, 'Downloads', x: 440, y: 510),
        ]),
      ]),
      width: 1200,
      height: 630,
    );
    return Response.ok(
      output,
      headers: {'Content-Type': 'image/png', 'Cache-Control': 'public, max-age=3600, s-maxage=86400'},
    );
  } catch (e) {
    print(e);
    return Response.notFound('Package not found');
  } finally {
    client.close();
  }
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
