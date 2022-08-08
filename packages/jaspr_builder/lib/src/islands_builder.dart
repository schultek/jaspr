import 'dart:async';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:jaspr/islands.dart';
import 'package:jaspr/jaspr.dart' show Key;
import 'package:source_gen/source_gen.dart';

final islandChecker = TypeChecker.fromRuntime(Island);
final keyChecker = TypeChecker.fromRuntime(Key);

class IslandBuilder extends Builder {
  IslandBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var lib = await buildStep.inputLibrary;

    var output = StringBuffer();

    for (var e in lib.units.expand((unit) => unit.classes)) {
      if (islandChecker.hasAnnotationOf(e)) {
        var params = e.constructors.first.parameters.where((e) => !keyChecker.isAssignableFromType(e.type));

        for (var param in params) {
          if (!param.isInitializingFormal) {
            throw UnsupportedError('Island components only support initializing formal constructor parameters.');
          }
        }

        output.writeln('class ${e.name}Island extends IslandComponent {\n'
            '${params.map((p) => '  final ${p.type.getDisplayString(withNullability: true)} ${p.name};\n').join()}'
            '\n'
            '  const ${e.name}Island('
            '${params.where((p) => p.isRequiredPositional).map((p) => 'this.${p.name}, ').join()}'
            '{${params.where((p) => !p.isRequiredPositional).map((p) => '${p.isRequiredNamed ? 'required ' : ''}this.${p.name}${p.hasDefaultValue ? ' = ${p.defaultValueCode}' : ''}, ').join()}'
            'super.containerBuilder, super.key}) : super(name: \'${e.name.toLowerCase()}\');\n\n'
            '  @override\n'
            '  Map<String, dynamic> get params => {${params.map((p) => "'${p.name}': ${p.name}").join(', ')}};\n\n'
            '  @override\n'
            '  Component buildChild(BuildContext context) {\n'
            '    return ${e.name}(${params.where((p) => p.isPositional).map((p) => p.name).followedBy(params.where((p) => p.isNamed).map((p) => '${p.name}: ${p.name}')).join(', ')});\n'
            '  }\n\n'
            '  static Component instantiate(BuildContext context, IslandParams params) {\n'
            '    return ${e.name}(${params.where((p) => p.isPositional).map((p) => 'params.get(\'${p.name}\')').followedBy(params.where((p) => p.isNamed).map((p) => '${p.name}: params.get(\'${p.name}\')')).join(', ')});\n'
            '  }\n'
            '}');
      }
    }

    if (output.isNotEmpty) {
      await buildStep.writeAsString(
        buildStep.inputId.changeExtension('.island.g.dart'),
        "import 'package:jaspr/islands.dart';\n"
        "import 'package:jaspr/jaspr.dart';\n"
        "import '${inputId.pathSegments.last}';\n\n$output",
      );
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.island.g.dart']
      };
}

class IslandsAppBuilder extends Builder {
  IslandsAppBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;

    var islandMatcher = RegExp('class (.*?)Island extends IslandComponent');

    var imports = <String, String>{};

    var assets = await buildStep.findAssets(Glob('**.island.g.dart')).asyncExpand((asset) async* {
      var content = await buildStep.readAsString(asset);
      var match = islandMatcher.allMatches(content);
      for (var m in match) {
        var name = m.group(1);
        if (name == null) continue;
        var prefix = imports[asset.path] ??= 'p${imports.length}';
        yield MapEntry(name, prefix);
      }
    }).toList();

    if (assets.isEmpty) {
      return;
    }

    var output = StringBuffer("import 'package:jaspr/islands.dart';\n");

    for (var path in imports.keys) {
      output.writeln("import '${path.startsWith('lib/') ? path.substring(4) : path}' deferred as ${imports[path]};");
    }

    output.writeln('\nvoid runIslandsApp() {\n'
        '  IslandsApp.runDeferred({');

    for (var asset in assets) {
      output.writeln(
          "    '${asset.key.toLowerCase()}': () => ${asset.value}.loadLibrary().then((_) => ${asset.value}.${asset.key}Island.instantiate),");
    }
    output.writeln('  });\n}');

    await buildStep.writeAsString(
      AssetId(inputId.package, inputId.path.replaceFirst('main.dart', 'islands.g.dart')),
      output.toString(),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        'main.dart': ['islands.g.dart']
      };
}
