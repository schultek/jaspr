import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';

import 'codec_resource.dart';

/// Builds modules for types annotated with @encoder / @decoder
class CodecModuleBuilder implements Builder {
  CodecModuleBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateCodecModule(buildStep);
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
        '.dart': ['.codec.json'],
      };

  Future<void> generateCodecModule(BuildStep buildStep) async {
    // Performance optimization
    var file = await buildStep.readAsString(buildStep.inputId);
    if (!file.contains('@decoder') && !file.contains('@encoder')) {
      return;
    }

    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    var library = await buildStep.inputLibrary;

    MethodElement? findEncoderForElement(InterfaceElement element) {
      var candidates = element.methods.where((m) => encoderChecker.firstAnnotationOfExact(m) != null);
      if (candidates.isEmpty) return null;
      if (candidates.length > 1) {
        log.severe(
            'Cannot have multiple methods annotated with @encoder in a single class. Failing element: ${element.name} in ${library.source.fullName}.');
      }
      var candidate = candidates.first;
      if (candidate.isPrivate) {
        log.severe(
            '@encoder cannot be used on private methods. Failing element: ${element.name}.${candidate.name}() in library ${library.source.fullName}.');
        return null;
      }
      if (candidate.isStatic) {
        log.severe(
            '@encoder cannot be used on static methods. Failing element: ${element.name}.${candidate.name}() in library ${library.source.fullName}.');
        return null;
      }
      if (candidate.parameters.isNotEmpty) {
        log.severe(
            'Methods annotated with @encoder must have no parameters. Failing element: ${element.name}.${candidate.name}() in library ${library.source.fullName}.');
        return null;
      }
      return candidate;
    }

    ExecutableElement? findDecoderForElement(InterfaceElement element) {
      var candidates = element.methods
          .cast<ExecutableElement>()
          .followedBy(element.constructors)
          .where((m) => decoderChecker.firstAnnotationOfExact(m) != null);
      if (candidates.isEmpty) return null;
      if (candidates.length > 1) {
        log.severe(
            'Cannot have multiple members annotated with @decoder in a single class. Failing element: ${element.name} in ${library.source.fullName}.');
      }
      var candidate = candidates.first;
      if (candidate.isPrivate) {
        log.severe(
            '@decoder cannot be used on private members. Failing element: ${element.name}.${candidate.name}() in library ${library.source.fullName}.');
        return null;
      }
      if (candidate is! ConstructorElement && !candidate.isStatic) {
        log.severe(
            '@decoder cannot be used on instance members. Failing element: ${element.name}.${candidate.name}() in library ${library.source.fullName}.');
        return null;
      }
      if (candidate.parameters.length != 1) {
        log.severe(
            'Members annotated with @decoder must have exactly one parameter. Failing element: ${element.name}.${candidate.name}() in library ${library.source.fullName}.');
        return null;
      }
      if (candidate.parameters.length != 1) {
        log.severe(
            'Members annotated with @decoder must have exactly one parameter. Failing element: ${element.name}.${candidate.name}() in library ${library.source.fullName}.');
        return null;
      }
      if (candidate.returnType != element.thisType) {
        log.severe(
            'Members annotated with @decoder must return an instance of the target type. Failing element: ${element.name}.${candidate.name}() in library ${library.source.fullName}.');
        return null;
      }
      return candidate;
    }

    var annotated = library.topLevelElements
        .whereType<InterfaceElement>()
        .map<(InterfaceElement, ExecutableElement, MethodElement)?>((element) {
          var decoder = findDecoderForElement(element);
          var encoder = findEncoderForElement(element);

          if (decoder == null && encoder == null) {
            return null;
          } else if (decoder == null) {
            log.severe(
                'Elements defining an @encoder must also define a @decoder. Failing element: ${element.name} in library ${library.source.fullName}.');
            return null;
          } else if (encoder == null) {
            log.severe(
                'Elements defining a @decoder must also define an @encoder. Failing element: ${element.name} in library ${library.source.fullName}.');
            return null;
          }

          if (element.isPrivate) {
            log.severe(
                '@decoder and @encoder can only be used on public elements. Failing element: ${element.name} in library ${library.source.fullName}.');
            return null;
          }

          if (decoder.parameters.first.type != encoder.returnType) {
            log.severe(
                'The @decoder parameter type must match the @encoder return type. Failing element: ${element.name} in library ${library.source.fullName}.');
            return null;
          }

          if (element is ExtensionTypeElement && element.interfaces.firstOrNull != element.representation.type) {
            log.severe(
                'Extension types using @decoder and @encoder must implement the representation type. Failing element: ${element.name} in library ${library.source.fullName}.');
            return null;
          }

          return (element, decoder, encoder);
        })
        .nonNulls
        .toList();

    if (annotated.isEmpty) {
      return;
    }

    var module = CodecModule.fromElements(annotated, buildStep);

    var outputId = buildStep.inputId.changeExtension('.codec.json');
    await buildStep.writeAsString(outputId, jsonEncode(module.serialize()));
  }
}

class CodecModule {
  final AssetId id;
  final List<CodecElement> elements;

  CodecModule({required this.id, required this.elements});

  factory CodecModule.fromElements(
      List<(InterfaceElement, ExecutableElement, MethodElement)> elements, BuildStep buildStep) {
    return CodecModule(
      id: buildStep.inputId,
      elements: [
        for (var (element, decoder, encoder) in elements) CodecElement.fromElement(element, decoder, encoder),
      ],
    );
  }

  factory CodecModule.deserialize(Map<String, dynamic> map) {
    return CodecModule(
      id: AssetId.deserialize(map['id']),
      elements: [
        for (var e in map['elements']) CodecElement.deserialize(e),
      ],
    );
  }

  Map<String, dynamic> serialize() => {
        'id': id.serialize(),
        'elements': [
          for (var e in elements) e.serialize(),
        ],
      };
}

class CodecElement {
  final String name;
  final String? extension;
  final String decoder;
  final String encoder;
  final String import;

  CodecElement({
    required this.name,
    this.extension,
    required this.decoder,
    required this.encoder,
    required this.import,
  });

  factory CodecElement.fromElement(InterfaceElement element, ExecutableElement decoder, MethodElement encoder) {
    return CodecElement(
      name: element is ExtensionTypeElement ? element.representation.type.getDisplayString() : element.name,
      extension: element is ExtensionTypeElement ? element.name : null,
      decoder: decoder.name,
      encoder: encoder.name,
      import: element.librarySource.uri.toString(),
    );
  }

  CodecElement.deserialize(Map<String, dynamic> map)
      : name = map['name'],
        extension = map['extension'],
        decoder = map['decoder'],
        encoder = map['encoder'],
        import = map['import'];

  Map<String, dynamic> serialize() => {
        'name': name,
        'extension': extension,
        'decoder': decoder,
        'encoder': encoder,
        'import': import,
      };
}
