import 'dart:io';

import 'package:jaspr_content/jaspr_content.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('AssetManager', () {
    late AssetManager assetManager;
    late MockPage page;
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('asset_manager_test_');
      assetManager = AssetManager(
        directory: tempDir.path,
        dataProperties: {'image', 'meta.image'},
      );
      page = MockPage();
      when(() => page.path).thenReturn('page1');
      when(() => page.data).thenReturn(<String, Object?>{} as PageDataMap);
      // Mock page.apply to update data in place for testing
      when(
        () => page.apply(
          data: any(named: 'data'),
          content: any(named: 'content'),
          mergeData: any(named: 'mergeData'),
        ),
      ).thenAnswer((invocation) {
        final data = invocation.namedArguments[#data] as Map<String, dynamic>?;
        final mergeData = invocation.namedArguments[#mergeData] as bool? ?? true;
        if (data != null) {
          if (mergeData) {
            when(() => page.data).thenReturn({...page.data, ...data} as PageDataMap);
          } else {
            when(() => page.data).thenReturn(data as PageDataMap);
          }
        }
      });
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    group('DataLoader', () {
      test('resolves relative paths in data properties', () async {
        when(() => page.data).thenReturn(
          {
                'image': 'image.png',
                'meta': {'image': 'meta_image.png'},
                'other': 'other.png',
              }
              as PageDataMap,
        );

        await assetManager.dataLoader.loadData(page);

        final data = page.data;
        expect(data['image'], '/assets/image.png');
        expect((data['meta'] as Map)['image'], '/assets/meta_image.png');
        expect(data['other'], 'other.png'); // Not in dataProperties
      });

      test('ignores absolute URLs and resolves root-relative paths', () async {
        when(() => page.data).thenReturn(
          {
                'image': '/absolute/image.png',
                'meta': {'image': 'https://example.com/image.png'},
              }
              as PageDataMap,
        );

        await assetManager.dataLoader.loadData(page);

        final data = page.data;
        // Documented behavior: "/" resolves relative to asset root
        expect(data['image'], '/assets/absolute/image.png');
        expect((data['meta'] as Map)['image'], 'https://example.com/image.png');
      });

      test('respects filterPages', () async {
        assetManager = AssetManager(
          directory: tempDir.path,
          dataProperties: {'image'},
          filterPages: (p) => p.path != 'excluded',
        );

        when(() => page.path).thenReturn('excluded');
        when(() => page.data).thenReturn({'image': 'image.png'} as PageDataMap);

        await assetManager.dataLoader.loadData(page);

        expect(page.data['image'], 'image.png'); // Should not change
      });
    });

    group('PageExtension', () {
      test('resolves relative paths in img src', () async {
        final nodes = <Node>[
          ElementNode('img', {'src': 'image.png'}, []),
          ElementNode('img', {'src': '/absolute/image.png'}, []),
          ElementNode('div', {}, [
            ElementNode('img', {'src': 'nested/image.png'}, []),
          ]),
        ];

        final result = await assetManager.pageExtension.apply(page, nodes);

        expect((result[0] as ElementNode).attributes['src'], '/assets/image.png');
        expect((result[1] as ElementNode).attributes['src'], '/assets/absolute/image.png');
        expect(
          ((result[2] as ElementNode).children!.first as ElementNode).attributes['src'],
          '/assets/nested/image.png',
        );
      });

      test('resolves relative paths in video/audio/source src', () async {
        final nodes = <Node>[
          ElementNode('video', {'src': 'video.mp4'}, []),
          ElementNode('audio', {'src': 'audio.mp3'}, []),
          ElementNode('source', {'src': 'source.mp4'}, []),
        ];

        final result = await assetManager.pageExtension.apply(page, nodes);

        expect((result[0] as ElementNode).attributes['src'], '/assets/video.mp4');
        expect((result[1] as ElementNode).attributes['src'], '/assets/audio.mp3');
        expect((result[2] as ElementNode).attributes['src'], '/assets/source.mp4');
      });
    });

    group('Middleware', () {
      test('serves assets for matching prefix', () async {
        File(p.join(tempDir.path, 'test.txt')).writeAsStringSync('hello');

        final middleware = assetManager.middleware;
        final handler = middleware((request) => Response.notFound('not found'));

        final request = Request('GET', Uri.parse('http://localhost/assets/test.txt'));
        final response = await handler(request);

        expect(response.statusCode, 200);
        expect(await response.readAsString(), 'hello');
      });

      test('calls inner handler for non-matching prefix', () async {
        final middleware = assetManager.middleware;
        final handler = middleware((request) => Response.ok('inner'));

        final request = Request('GET', Uri.parse('http://localhost/other/test.txt'));
        final response = await handler(request);

        expect(response.statusCode, 200);
        expect(await response.readAsString(), 'inner');
      });
    });

    group('resolveAsset', () {
      test('resolves paths directly', () {
        when(() => page.path).thenReturn('dir/page.html');

        expect(assetManager.resolveAsset('image.png', page), '/assets/dir/image.png');
        expect(assetManager.resolveAsset('/absolute.png', page), '/assets/absolute.png');
        expect(assetManager.resolveAsset('https://example.com/logo.png', page), 'https://example.com/logo.png');
      });
    });
  });
}
