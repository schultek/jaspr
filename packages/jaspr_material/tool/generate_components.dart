import 'dart:convert';
import 'dart:io';

void main() async {
  var temp = Directory('./tool/temp');
  if (temp.existsSync()) {
    temp.deleteSync(recursive: true);
  }
  temp.createSync(recursive: true);

  await $('git clone https://github.com/material-components/material-web', temp.path);
  await $('wca analyze --format=json --outFile=all.json', '${temp.path}/material-web');

  var mwb = Directory('${temp.path}/material-web-build')..createSync(recursive: true);
  File('${mwb.path}/package.json').writeAsStringSync('''{
    "name": "material-web-build",
    "version": "1.0.0",
    "dependencies": {
      "@material/web": "^1.4.1"

    }
  }''');
  await $('npm i', mwb.path);
  await $('npm install rollup @rollup/plugin-node-resolve', mwb.path);

  var spec = jsonDecode(File('${temp.path}/material-web/all.json').readAsStringSync());
  var all = <String>[];

  for (var component in spec["tags"] as Iterable) {
    var {'name': name} = component;
    if (!name.startsWith('md-') || name.startsWith('md-test-')) continue;
    await buildComponent(component, mwb);
    generateComponent(component);
    all.add(name.replaceAll('-', '_'));
  }

  all.sort();

  File('lib/src/all.dart').writeAsStringSync(all.map((n) => "export './components/$n.dart';").join('\n'));
}

Future<void> buildComponent(Map<String, dynamic> component, Directory mwb) async {
  var {
    "name": String name,
    "path": String path,
  } = component;

  var import = path.substring(2).replaceFirst('.ts', '.js');

  var entry = File('${mwb.path}/src/$name.js');
  entry.createSync(recursive: true);
  entry.writeAsStringSync("import '@material/web/$import';");

  await $('npx rollup -p @rollup/plugin-node-resolve ./src/$name.js -o ./build/$name.js', mwb.path);
  await $('cp ${mwb.path}/build/$name.js lib/js/$name.js');
}

void generateComponent(Map<String, dynamic> component) {
  var name = component['name'] as String;
  var attrs = component['attributes'] as List? ?? [];

  String constructor() => attrs.map((a) {
        var prop = (a['name'] as String).toCamelCase();
        var def = a['default'];
        return '\n    ${def == null ? 'required ' : ''}this.$prop${def != null ? ' = $def' : ''},';
      }).join();

  String toDartType(type) => switch (type) {
        'true' || 'false' || 'boolean' => 'bool',
        'string' => 'String',
        'number' => 'double',
        _ => 'Object',
      };

  String props() => attrs.map((a) {
        var {'name': name, 'type': type} = a;
        var prop = (name as String).toCamelCase();
        var dartType = toDartType(type);
        return '\n  final $dartType $prop;';
      }).join();

  String params() => attrs.map((a) {
        var {'name': name, 'type': type} = a;
        var prop = (name as String).toCamelCase();
        var dartType = toDartType(type);
        var isString = dartType == "String";
        var isBool = dartType == "bool";
        return "\n        ${isBool ? 'if ($prop) ' : ''}'$name': ${isBool ? "''" : isString ? prop : "'\$$prop'"},";
      }).join();

  var fileName = name.replaceAll('-', '_');
  var className = name.toPascalCase();

  var file = File('lib/src/components/$fileName.dart');

  file.createSync(recursive: true);
  file.writeAsStringSync('''
import 'package:jaspr/jaspr.dart';

class $className extends StatelessComponent {
  const $className({${constructor()}
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });
${props()}
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/$name.js', async: true, []),
    ]);
    yield DomComponent(
      tag: '$name',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,${params()}
      },
      events: events,
      children: children,
    );
  }
}
  ''');
}

Future<void> $(String command, [String? workingDirectory]) async {
  var [executable, ...args] = command.split(" ");
  var process = await Process.start(executable, args, runInShell: true, workingDirectory: workingDirectory);
  print(">> $command");
  process.stdout.listen((d) => stdout.add(d));
  process.stderr.listen((d) => stderr.add(d));
  await process.exitCode;
}

extension on String {
  String toCapitalCase() => substring(0, 1).toUpperCase() + substring(1).toLowerCase();
  String toCamelCase() => split('-').indexed.map((s) => s.$1 == 0 ? s.$2.toLowerCase() : s.$2.toCapitalCase()).join();
  String toPascalCase() => split('-').map((s) => s.toCapitalCase()).join();
}
