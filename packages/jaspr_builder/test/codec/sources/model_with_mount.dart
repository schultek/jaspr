import 'dart:convert';

const modelWithMountSources = {
  'site|lib/model_with_mount.dart': '''
    import 'package:jaspr/jaspr.dart';

    class ModelWithMountPositional {
      ModelWithMountPositional(this.child);

      final Component child;

      @decoder
      factory ModelWithMountPositional.fromRaw(Map<String, dynamic> raw, ComponentMount mount) {
        return ModelWithMountPositional(mount(raw['child'] as String));
      }

      @encoder
      Map<String, dynamic> toRaw() => {'child': child};
    }

    class ModelWithMountNamed {
      ModelWithMountNamed(this.child);

      final Component child;

      @decoder
      factory ModelWithMountNamed.fromRaw(Map<String, dynamic> raw, {ComponentMount? mount}) {
        return ModelWithMountNamed(mount!(raw['child'] as String));
      }

      @encoder
      Map<String, dynamic> toRaw() => {'child': child};
    }
  ''',
};

final modelWithMountOutputs = {
  'site|lib/model_with_mount.codec.json': jsonEncode({
    'elements': [
      {
        'name': 'ModelWithMountPositional',
        'decoder': 'fromRaw',
        'encoder': 'toRaw',
        'rawType': 'Map<String, dynamic>',
        'import': 'package:site/model_with_mount.dart',
        'hasMount': true,
      },
      {
        'name': 'ModelWithMountNamed',
        'decoder': 'fromRaw',
        'encoder': 'toRaw',
        'rawType': 'Map<String, dynamic>',
        'import': 'package:site/model_with_mount.dart',
        'hasMount': true,
        'mountParam': 'mount',
      },
    ],
  }),
};

const modelWithInvalidMountSources = {
  'site|lib/model_invalid_mount.dart': '''
    import 'package:jaspr/jaspr.dart';

    class ModelInvalidMount {
      ModelInvalidMount(this.a);

      final String a;

      @decoder
      factory ModelInvalidMount.fromRaw(Map<String, dynamic> raw, int invalidMount) {
        return ModelInvalidMount(raw['a'] as String);
      }

      @encoder
      Map<String, dynamic> toRaw() => {'a': a};
    }
  ''',
};
