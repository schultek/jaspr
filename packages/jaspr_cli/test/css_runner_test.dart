import 'package:jaspr_cli/src/dev/css_runner.dart';
import 'package:test/test.dart';

void main() {
  group('uriInPubCache', () {
    test('detects the default pub cache on Windows', () {
      final uri = Uri.file(
        r'C:\Users\me\AppData\Local\Pub\Cache\hosted\pub.dev\jaspr-0.24.0\lib\jaspr.dart',
        windows: true,
      );
      expect(uriInPubCache(uri), isTrue);
    });

    test('detects git dependencies in the pub cache on Windows', () {
      final uri = Uri.file(
        r'C:\Users\me\AppData\Local\Pub\Cache\git\jaspr-abc123\packages\jaspr\lib\jaspr.dart',
        windows: true,
      );
      expect(uriInPubCache(uri), isTrue);
    });

    test('detects the default pub cache on macOS and Linux', () {
      final uri = Uri.file('/Users/me/.pub-cache/hosted/pub.dev/jaspr-0.24.0/lib/jaspr.dart', windows: false);
      expect(uriInPubCache(uri), isTrue);
    });

    test('does not match project sources', () {
      expect(uriInPubCache(Uri.file(r'C:\Users\me\projects\my_app\lib\main.dart', windows: true)), isFalse);
      expect(uriInPubCache(Uri.file('/Users/me/projects/my_app/lib/main.dart', windows: false)), isFalse);
    });
  });
}
