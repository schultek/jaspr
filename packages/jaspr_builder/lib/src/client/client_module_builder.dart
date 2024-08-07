import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import '../codec/codec_resource.dart';
import '../utils.dart';

/// Builds modules for components annotated with @client
class ClientModuleBuilder implements Builder {
  ClientModuleBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateClientModule(buildStep);
    } on SyntaxErrorInAssetException {
      rethrow;
    } catch (e, st) {
      print('An unexpected error occurred.\n'
          'This is probably a bug in jaspr_builder.\n'
          'Please report this here: '
          'https://github.com/schultek/jaspr/issues\n\n'
          'The error was:\n$e\n\n$st');
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        'lib/{{file}}.dart': ['lib/{{file}}.client.json', 'web/{{file}}.client.dart'],
      };

  Future<void> generateClientModule(BuildStep buildStep) async {
    // Performance optimization
    var file = await buildStep.readAsString(buildStep.inputId);
    if (!file.contains('@client')) {
      return;
    }

    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    var library = await buildStep.inputLibrary;
    var reader = LibraryReader(library);

    var clients = reader.annotatedWithExact(clientChecker).map((e) => e.element);

    var annotated = clients.toSet();

    if (annotated.isEmpty) {
      return;
    }

    if (annotated.length > 1) {
      log.severe(
          "Cannot have multiple components annotated with @client in a single library. Failing library: ${library.source.fullName}.");
    }

    var element = annotated.first;

    if (element is! ClassElement) {
      log.severe(
          '@client can only be applied on classes. Failing element: ${element.name} in library ${library.source.fullName}.');
      return;
    }

    if (!componentChecker.isAssignableFrom(element)) {
      log.severe(
          '@client can only be applied on classes extending Component. Failing element: ${element.name} in library ${library.source.fullName}.');
      return;
    }

    var resource = await buildStep.fetchResource(codecResource);
    var codecs = await resource.readCodecs(buildStep);
    var module = ClientModule.fromElement(element, codecs, buildStep);

    var outputId = buildStep.inputId.changeExtension('.client.json');
    await buildStep.writeAsString(outputId, jsonEncode(module.serialize()));

    await generateWebEntrypoint(module, buildStep);
  }

  Future<void> generateWebEntrypoint(ClientModule module, BuildStep buildStep) async {
    var webId =
        AssetId(module.id.package, module.id.path.replaceFirst('lib/', 'web/').replaceFirst('.dart', '.client.dart'));

    var moduleImport = 'package:${module.id.package}/${module.id.path.replaceFirst('lib/', '')}';
    var paramImports = module.params.expand((p) => p.imports).toSet();

    var webSource = DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/browser.dart';
      import '$moduleImport' as a;
      ${paramImports.map((p) => "import '$p';").join('\n  ')}
            
      void main() {
        runAppWithParams(getComponentForParams);
      }
      
      Component getComponentForParams(ConfigParams p) {
        return a.${module.name}(${module.params.where((p) => !p.isNamed).map((p) => p.decoder).followedBy(module.params.where((p) => p.isNamed).map((p) => '${p.name}: ${p.decoder}')).join(', ')});
      }
    ''');

    await buildStep.writeAsString(webId, webSource);
  }
}

class ClientModule {
  final String name;
  final AssetId id;
  final List<ClientParam> params;

  ClientModule({required this.name, required this.id, required this.params});

  static ClientModule fromElement(ClassElement element, Codecs codecs, BuildStep buildStep) {
    var params = getParamsFor(element, codecs);

    return ClientModule(
      name: element.name,
      id: buildStep.inputId,
      params: params,
    );
  }

  factory ClientModule.deserialize(Map<String, dynamic> map) {
    return ClientModule(
      name: map['name'],
      id: AssetId.deserialize(map['id']),
      params: [
        for (var p in map['params']) ClientParam.deserialize(p),
      ],
    );
  }

  Map<String, dynamic> serialize() => {
        'name': name,
        'id': id.serialize(),
        'params': [
          for (var p in params) p.serialize(),
        ],
      };
}

class ClientParam {
  final String name;
  final bool isNamed;
  final String decoder;
  final String encoder;
  final Set<String> imports;

  ClientParam({
    required this.name,
    this.isNamed = false,
    required this.decoder,
    required this.encoder,
    required this.imports,
  });

  ClientParam.deserialize(Map<String, dynamic> map)
      : name = map['name'],
        isNamed = map['isNamed'],
        decoder = map['decoder'],
        encoder = map['encoder'],
        imports = (map['imports'] as List).toSet().cast();

  Map<String, dynamic> serialize() => {
        'name': name,
        'isNamed': isNamed,
        'decoder': decoder,
        'encoder': encoder,
        'imports': imports.toList(),
      };
}

List<ClientParam> getParamsFor(ClassElement e, Codecs codecs) {
  final constr = e.constructors.first;
  var params = constr.parameters.where((e) => !keyChecker.isAssignableFromType(e.type)).toList();

  for (var param in params) {
    if (!param.isInitializingFormal) {
      throw UnsupportedError('Client components only support initializing formal constructor parameters. '
          'Failing element: ${e.name}.${constr.name}($param)');
    }
  }

  return params.map((p) {
    var decoder = codecs.getDecoderFor(p.type, 'p.get(\'${p.name}\')');
    var encoder = codecs.getEncoderFor(p.type, 'c.${p.name}');

    return ClientParam(
      name: p.name,
      isNamed: p.isNamed,
      decoder: decoder.$1,
      encoder: encoder.$1,
      imports: {...decoder.$2, ...encoder.$2},
    );
  }).toList();
}
