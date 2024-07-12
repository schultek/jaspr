import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:jaspr/jaspr.dart' show DecoderAnnotation, EncoderAnnotation;
import 'package:source_gen/source_gen.dart';

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
      log.warning("Cannot have multiple components annotated with @client in a single library.");
    }

    var element = annotated.first;

    if (element is! ClassElement) {
      log.warning('@client can only be applied on classes. Failing element: ${element.name}');
      return;
    }

    if (!componentChecker.isAssignableFrom(element)) {
      log.warning('@client can only be applied on classes extending Component. Failing element: ${element.name}');
      return;
    }

    var module = await ClientModule.fromElement(element, buildStep);

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

  static Future<ClientModule> fromElement(ClassElement element, BuildStep buildStep) async {
    var params = getParamsFor(element);

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

List<ClientParam> getParamsFor(ClassElement e) {
  var params = e.constructors.first.parameters.where((e) => !keyChecker.isAssignableFromType(e.type)).toList();

  for (var param in params) {
    if (!param.isInitializingFormal) {
      throw UnsupportedError('Client components only support initializing formal constructor parameters.');
    }
  }

  return params.map((p) {
    var decoder = getDecoderFor(p);
    var encoder = getEncoderFor(p);

    return ClientParam(
      name: p.name,
      isNamed: p.isNamed,
      decoder: decoder.$1,
      encoder: encoder.$1,
      imports: [...decoder.$2, ...encoder.$2].map((l) => l.source.uri.toString()).toSet(),
    );
  }).toList();
}

(String, Set<LibraryElement>) getDecoderFor(ParameterElement p) {
  var type = p.type;

  var value = 'p.get(\'${p.name}\')';
  var decoder = type.acceptWithArgument(DecoderVisitor(), value);

  if (decoder.$1 == null) {
    return (value, {});
  }

  return (decoder.$1!, decoder.$2);
}

typedef DecoderResult = (String?, Set<LibraryElement>);

class DecoderVisitor extends UnifyingTypeVisitorWithArgument<DecoderResult, String> {
  @override
  DecoderResult visitDartType(DartType type, String argument) {
    return (null, {});
  }

  @override
  DecoderResult visitInterfaceType(InterfaceType type, String argument) {
    if (type.isDartCoreList) {
      var nested = type.typeArguments.first.acceptWithArgument(this, 'i');
      if (nested.$1 != null) {
        return ('($argument as List).map((i) => ${nested.$1}).toList()', nested.$2);
      }
    } else if (type.isDartCoreMap) {
      var nested = type.typeArguments[1].acceptWithArgument(this, 'v');
      if (nested.$1 != null) {
        return ('($argument as Map).map((k, v) => MapEntry(k, ${nested.$1}))', nested.$2);
      }
    } else if (findAnnotatedDecoder(type) case final decoder?) {
      return ('${type.element.name}.$decoder($argument)', {type.element.library});
    }
    return super.visitInterfaceType(type, argument);
  }
}

String? findAnnotatedDecoder(InterfaceType type) {
  var decoder = type.methods.where((m) => m.isStatic && decoderChecker.firstAnnotationOfExact(m) != null).firstOrNull;
  return decoder?.name;
}

final decoderChecker = TypeChecker.fromRuntime(DecoderAnnotation);

(String, Set<LibraryElement>) getEncoderFor(ParameterElement p) {
  var type = p.type;

  var value = 'c.${p.name}';
  var encoder = type.acceptWithArgument(EncoderVisitor(), value);

  if (encoder.$1 == null) {
    return (value, {});
  }

  return (encoder.$1!, encoder.$2);
}

typedef EncoderResult = (String?, Set<LibraryElement>);

class EncoderVisitor extends UnifyingTypeVisitorWithArgument<EncoderResult, String> {
  @override
  EncoderResult visitDartType(DartType type, String argument) {
    return (null, {});
  }

  @override
  EncoderResult visitInterfaceType(InterfaceType type, String argument) {
    if (type.isDartCoreList) {
      var nested = type.typeArguments.first.acceptWithArgument(this, 'i');
      if (nested.$1 != null) {
        return ('$argument.map((i) => ${nested.$1}).toList()', nested.$2);
      }
    } else if (type.isDartCoreMap) {
      var nested = type.typeArguments[1].acceptWithArgument(this, 'v');
      if (nested.$1 != null) {
        return ('$argument.map((k, v) => MapEntry(k, ${nested.$1}))', nested.$2);
      }
    } else if (findAnnotatedEncoder(type) case final encoder?) {
      return ('$argument.$encoder()', {type.element.library});
    }
    return super.visitInterfaceType(type, argument);
  }
}

String? findAnnotatedEncoder(InterfaceType type) {
  var encoder = type.methods.where((m) => !m.isStatic && encoderChecker.firstAnnotationOfExact(m) != null).firstOrNull;
  return encoder?.name;
}

final encoderChecker = TypeChecker.fromRuntime(EncoderAnnotation);
