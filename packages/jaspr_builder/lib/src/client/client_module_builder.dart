import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import '../codec/codecs.dart';
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
      print(
        'An unexpected error occurred.\n'
        'This is probably a bug in jaspr_builder.\n'
        'Please report this here: '
        'https://github.com/schultek/jaspr/issues\n\n'
        'The error was:\n$e\n\n$st',
      );
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    'lib/{{file}}.dart': ['lib/{{file}}.client.json', 'lib/{{file}}.client.dart'],
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
        "Cannot have multiple components annotated with @client in a single library. Failing library: ${library.firstFragment.source.fullName}.",
      );
    }

    var element = annotated.first;

    if (element is! ClassElement) {
      log.severe(
        '@client can only be applied on classes. Failing element: ${element.name} in library ${library.firstFragment.source.fullName}.',
      );
      return;
    }

    if (!componentChecker.isAssignableFrom(element)) {
      log.severe(
        '@client can only be applied on classes extending Component. Failing element: ${element.name} in library ${library.firstFragment.source.fullName}.',
      );
      return;
    }

    var codecs = await buildStep.loadCodecs();
    ClientModule module;

    try {
      module = ClientModule.fromElement(element, codecs, buildStep);
    } on UnsupportedError catch (e) {
      log.severe(e.message);
      return;
    }

    var outputId = buildStep.inputId.changeExtension('.client.json');
    await buildStep.writeAsString(outputId, jsonEncode(module.serialize()));

    await generateWebEntrypoint(module, buildStep);
  }

  Future<void> generateWebEntrypoint(ClientModule module, BuildStep buildStep) async {
    var source =
        '''
      $generationHeader
      
      import 'package:jaspr/browser.dart';
      [[/]]
            
      Component getComponentForParams(Map<String, dynamic> p) {
        return ${module.componentFactory()};
      }
    ''';
    source = ImportsWriter().resolve(source);
    source = DartFormatter(
      languageVersion: DartFormatter.latestShortStyleLanguageVersion,
      pageWidth: 120,
    ).format(source);

    var moduleId = AssetId.resolve(Uri.parse(module.import));

    var entryId = AssetId(moduleId.package, moduleId.path.replaceFirst('.dart', '.client.dart'));
    await buildStep.writeAsString(entryId, source);
  }
}

class ClientModule {
  final String name;
  final AssetId id;
  final String import;
  final List<ClientParam> params;

  ClientModule({required this.name, required this.id, required this.import, required this.params});

  static ClientModule fromElement(ClassElement element, Codecs codecs, BuildStep buildStep) {
    var params = getParamsFor(element, codecs);

    return ClientModule(
      name: element.name ?? '',
      id: buildStep.inputId,
      import: buildStep.inputId.toImportUrl(),
      params: params,
    );
  }

  String resolveId(String package) {
    final a = package != id.package ? '${id.package}:' : '';
    final b = path.url.withoutExtension(id.path).replaceFirst('lib/', '');
    return '$a$b';
  }

  factory ClientModule.deserialize(Map<String, dynamic> map) {
    return ClientModule(
      name: map['name'],
      id: AssetId.deserialize(map['id']),
      import: map['import'],
      params: [for (var p in map['params']) ClientParam.deserialize(p)],
    );
  }

  Map<String, dynamic> serialize() => {
    'name': name,
    'id': id.serialize(),
    'import': import,
    'params': [for (var p in params) p.serialize()],
  };

  String componentFactory() {
    return '[[$import]].$name(${params.where((p) => !p.isNamed).map((p) => p.decoder).followedBy(params.where((p) => p.isNamed).map((p) => '${p.name}: ${p.decoder}')).join(', ')})';
  }
}

class ClientParam {
  final String name;
  final bool isNamed;
  final String decoder;
  final String encoder;

  ClientParam({required this.name, this.isNamed = false, required this.decoder, required this.encoder});

  ClientParam.deserialize(Map<String, dynamic> map)
    : name = map['name'],
      isNamed = map['isNamed'],
      decoder = map['decoder'],
      encoder = map['encoder'];

  Map<String, dynamic> serialize() => {'name': name, 'isNamed': isNamed, 'decoder': decoder, 'encoder': encoder};
}

List<ClientParam> getParamsFor(ClassElement e, Codecs codecs) {
  final constr = e.constructors.first;
  var params = constr.formalParameters.where((e) => !keyChecker.isAssignableFromType(e.type)).toList();

  for (var param in params) {
    if (!param.isInitializingFormal) {
      throw UnsupportedError(
        'Client components only support initializing formal constructor parameters. '
        'Failing element: ${e.name}.${constr.name}($param)',
      );
    }
  }

  return params.map((p) {
    try {
      var decoder = codecs.getDecoderFor(p.type, "p['${p.name}']");
      var encoder = codecs.getEncoderFor(p.type, 'c.${p.name}');
      return ClientParam(name: p.name ?? '', isNamed: p.isNamed, decoder: decoder, encoder: encoder);
    } on InvalidParameterException catch (_) {
      throw UnsupportedError(
        '@client components only support parameters of primitive serializable types or types that define @decoder and @encoder methods. '
        'Failing parameter: [$p] in ${e.name}.${constr.name}()',
      );
    }
  }).toList();
}
