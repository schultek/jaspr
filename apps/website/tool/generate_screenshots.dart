import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  final force = args.contains('--force') || args.contains('-f');
  await generateShowcaseScreenshots(force: force);
}

/// Takes screenshots for all showcase items defined in `content/_data/showcase.yaml`.
Future<void> generateShowcaseScreenshots({bool force = false}) async {
  // Find showcase.yaml
  File? yamlFile;
  Directory? webDir;

  const candidates = [
    ('content/_data/showcase.yaml', 'web'),
    ('apps/website/content/_data/showcase.yaml', 'apps/website/web'),
  ];

  for (final (yamlPath, webPath) in candidates) {
    final file = File(yamlPath);
    if (file.existsSync()) {
      yamlFile = file;
      webDir = Directory(webPath);
      break;
    }
  }

  if (yamlFile == null || webDir == null) {
    print('Error: Could not find showcase.yaml in candidates: ${candidates.map((c) => c.$1).toList()}');
    return;
  }

  final content = await yamlFile.readAsString();
  final dynamic yamlData = loadYaml(content);
  if (yamlData is! YamlList) {
    print('Error: showcase.yaml content is not a YAML list.');
    return;
  }

  final itemsToCapture = <(String title, String url, File targetFile)>[];

  for (final item in yamlData) {
    if (item is! YamlMap) continue;

    final url = item['url']?.toString();
    final title = item['title']?.toString() ?? 'Showcase Site';
    var image = item['image']?.toString();

    if (url == null || url.isEmpty) continue;

    if (image == null || image.isEmpty) {
      final slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
      image = 'images/showcase/$slug.png';
    }

    final targetFile = File('${webDir.path}/$image');
    if (!force && targetFile.existsSync() && targetFile.lengthSync() > 0) {
      continue;
    }

    itemsToCapture.add((title, url, targetFile));
  }

  if (itemsToCapture.isEmpty) {
    print('All screenshots are already up to date. Run with --force to re-capture all.');
    return;
  }

  final chromePath = await _findChrome();
  if (chromePath == null) {
    print('Error: Google Chrome / Chromium not found. Please install Chrome or set CHROME_PATH.');
    return;
  }

  print('Capturing ${itemsToCapture.length} screenshot(s) using Chrome DevTools Protocol...');

  final tempProfile = await Directory.systemTemp.createTemp('chrome_cdp_profile_');
  Process? chromeProcess;

  try {
    const port = 9333;
    chromeProcess = await Process.start(chromePath, [
      '--headless=new',
      '--disable-gpu',
      '--remote-debugging-port=$port',
      '--user-data-dir=${tempProfile.path}',
      'about:blank',
    ]);

    // Wait until Chrome is accepting connections
    var connected = false;
    for (var i = 0; i < 30; i++) {
      try {
        final s = await Socket.connect('127.0.0.1', port, timeout: const Duration(milliseconds: 200));
        await s.close();
        connected = true;
        break;
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    if (!connected) {
      print('Could not connect to Chrome DevTools port $port. Falling back to single-shot CLI.');
      await _captureFallback(chromePath, itemsToCapture);
      return;
    }

    final httpClient = HttpClient();

    for (var idx = 0; idx < itemsToCapture.length; idx++) {
      final (title, url, targetFile) = itemsToCapture[idx];
      print('[${idx + 1}/${itemsToCapture.length}] Capturing screenshot for $title ($url)...');
      await targetFile.parent.create(recursive: true);

      try {
        final req = await httpClient.putUrl(Uri.parse('http://127.0.0.1:$port/json/new?$url'));
        final res = await req.close();
        final body = await res.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final targetId = json['id'] as String?;
        final wsUrl = json['webSocketDebuggerUrl'] as String?;

        if (wsUrl == null) {
          throw Exception('No webSocketDebuggerUrl returned for $url');
        }

        final ws = await WebSocket.connect(wsUrl);
        var reqId = 1;
        final pending = <int, Completer<Map<String, dynamic>>>{};
        final events = StreamController<Map<String, dynamic>>.broadcast();

        ws.listen((data) {
          try {
            final map = jsonDecode(data as String) as Map<String, dynamic>;
            if (map.containsKey('id')) {
              pending[map['id'] as int]?.complete(map);
            } else if (map.containsKey('method')) {
              events.add(map);
            }
          } catch (_) {}
        });

        Future<Map<String, dynamic>> send(String method, [Map<String, dynamic>? params]) {
          final id = reqId++;
          final completer = Completer<Map<String, dynamic>>();
          pending[id] = completer;
          ws.add(jsonEncode({'id': id, 'method': method, 'params': ?params}));
          return completer.future;
        }

        await send('Page.enable');

        // Set exact 1280x800 viewport override
        await send('Emulation.setDeviceMetricsOverride', {
          'width': 1280,
          'height': 800,
          'deviceScaleFactor': 1,
          'mobile': false,
        });

        // Wait for page load event (or max 12s)
        final loadFuture = events.stream.firstWhere((e) => e['method'] == 'Page.loadEventFired');
        await loadFuture.timeout(const Duration(seconds: 12), onTimeout: () => {});

        // Wait 10 seconds for all images, webfonts, animations, and client hydration to load
        print('  Waiting 10s for page images & scripts to settle...');
        await Future.delayed(const Duration(seconds: 10));

        // Dismiss & remove cookie banners, and reset any margins added by cookie notices
        await send('Runtime.evaluate', {
          'expression': '''
            (() => {
              // 1. Click accept/dismiss buttons if present
              document.querySelectorAll('button, a').forEach(el => {
                const text = (el.textContent || '').trim().toLowerCase();
                if (el.closest('#cookie-notice, .glue-cookie-notification-bar, #onetrust-consent-sdk, [class*="cookie"]') &&
                    (text === 'ok, got it' || text === 'hide' || text.includes('accept') || text.includes('got it') || text === 'i agree')) {
                  try { el.click(); } catch (_) {}
                }
              });

              // 2. Hide and remove banner elements
              const style = document.createElement('style');
              style.textContent = `
                #cookie-notice,
                .glue-cookie-notification-bar,
                #onetrust-consent-sdk,
                #onetrust-banner-sdk,
                .cc-window,
                .cookie-banner,
                .cookie-consent,
                [id*="cookie" i],
                [class*="cookie" i],
                [id*="consent" i],
                [class*="consent" i] {
                  display: none !important;
                  visibility: hidden !important;
                  opacity: 0 !important;
                  pointer-events: none !important;
                  height: 0 !important;
                  max-height: 0 !important;
                  margin: 0 !important;
                  padding: 0 !important;
                }
              `;
              document.head.appendChild(style);
              document.querySelectorAll('#cookie-notice, .glue-cookie-notification-bar, #onetrust-consent-sdk, .cc-window, [id*="cookie" i]').forEach(el => el.remove());

              // 3. Reset margins / padding that might have pushed page content or left a white strip
              document.body.style.marginBottom = '0px';
              document.body.style.paddingBottom = '0px';
              document.documentElement.style.marginBottom = '0px';
              document.documentElement.style.paddingBottom = '0px';
            })()
          ''',
        });

        await Future.delayed(const Duration(milliseconds: 500));

        // Capture screenshot with exact 1280x800 clip matching viewport
        final screenshotRes = await send('Page.captureScreenshot', {
          'format': 'png',
          'clip': {'x': 0, 'y': 0, 'width': 1280, 'height': 800, 'scale': 1},
        });

        final result = screenshotRes['result'] as Map<String, dynamic>?;
        final data = result?['data'] as String?;
        if (data == null) {
          throw Exception('No screenshot data returned');
        }

        final bytes = base64Decode(data);
        await targetFile.writeAsBytes(bytes);

        await ws.close();

        if (targetId != null) {
          try {
            final closeReq = await httpClient.putUrl(Uri.parse('http://127.0.0.1:$port/json/close/$targetId'));
            final closeRes = await closeReq.close();
            await closeRes.drain();
          } catch (_) {}
        }

        if (Platform.isMacOS) {
          await Process.run('sips', ['-Z', '640', targetFile.path]);
        }
        print('  Successfully saved and resized: ${targetFile.path}');
      } catch (e) {
        print('  Error capturing $url via CDP: $e. Falling back to single-shot CLI.');
        await _captureSingleCli(chromePath, url, targetFile);
      }
    }
  } catch (e) {
    print('Error during CDP execution: $e');
  } finally {
    chromeProcess?.kill();
    try {
      if (tempProfile.existsSync()) {
        await tempProfile.delete(recursive: true);
      }
    } catch (_) {}
  }

  print('Finished capturing showcase screenshots.');
}

Future<void> _captureFallback(String chromePath, List<(String title, String url, File targetFile)> items) async {
  for (final (title, url, targetFile) in items) {
    print('Fallback capturing $title ($url)...');
    await _captureSingleCli(chromePath, url, targetFile);
  }
}

Future<void> _captureSingleCli(String chromePath, String url, File targetFile) async {
  try {
    final result = await Process.run(
      chromePath,
      [
        '--headless=new',
        '--disable-gpu',
        '--window-size=1280,800',
        '--screenshot=${targetFile.path}',
        url,
      ],
    );

    if (result.exitCode == 0 && targetFile.existsSync()) {
      if (Platform.isMacOS) {
        await Process.run('sips', ['-Z', '640', targetFile.path]);
      }
      print('  Successfully captured and resized: ${targetFile.path}');
    }
  } catch (e) {
    print('  Error capturing $url: $e');
  }
}

Future<String?> _findChrome() async {
  final envPath = Platform.environment['CHROME_PATH'];
  if (envPath != null && File(envPath).existsSync()) {
    return envPath;
  }

  if (Platform.isMacOS) {
    const macPath = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
    if (File(macPath).existsSync()) {
      return macPath;
    }
  }

  for (final binary in ['google-chrome', 'chromium', 'chromium-browser']) {
    try {
      final result = await Process.run('which', [binary]);
      if (result.exitCode == 0) {
        final path = result.stdout.toString().trim();
        if (path.isNotEmpty && File(path).existsSync()) {
          return path;
        }
      }
    } catch (_) {}
  }

  return null;
}
