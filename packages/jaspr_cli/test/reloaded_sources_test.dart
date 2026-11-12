import 'package:jaspr_cli/src/dev/reloaded_sources.dart';
import 'package:test/test.dart';

Map<String, Object> source(String module, String src) => {
  'src': src,
  'module': module,
  'libraries': [module],
};

void main() {
  group('ReloadedSources', () {
    test('accumulates changes across builds', () {
      final sources = ReloadedSources();
      final a = source('package:app/a.dart', '/packages/app/a.ddc.js');
      final b = source('package:app/b.dart', '/packages/app/b.ddc.js');

      sources.add('package:app/a.dart', a);
      sources.add('package:app/b.dart', b);

      expect(sources.toJson(), equals([a, b]));
    });

    test('removes delivered entries after a reload', () {
      final sources = ReloadedSources();
      final a = source('package:app/a.dart', '/packages/app/a.ddc.js');
      sources.add('package:app/a.dart', a);

      final delivered = sources.snapshot();
      sources.removeDelivered(delivered);

      expect(sources.toJson(), isEmpty);
    });

    test('keeps entries that a newer build changed while a reload was running', () {
      final sources = ReloadedSources();
      final a1 = source('package:app/a.dart', '/packages/app/a.ddc.js');
      final b = source('package:app/b.dart', '/packages/app/b.ddc.js');
      sources.add('package:app/a.dart', a1);
      sources.add('package:app/b.dart', b);

      // A reload starts and delivers a1 and b.
      final delivered = sources.snapshot();

      // A newer build changes a again and adds c before the reload finishes.
      final a2 = source('package:app/a.dart', '/packages/app/a.ddc.js');
      final c = source('package:app/c.dart', '/packages/app/c.ddc.js');
      sources.add('package:app/a.dart', a2);
      sources.add('package:app/c.dart', c);

      sources.removeDelivered(delivered);

      expect(sources.toJson(), equals([a2, c]));
    });
  });
}
