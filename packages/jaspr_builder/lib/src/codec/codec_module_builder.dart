// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';

import 'codecs.dart';

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
    final libName = library.firstFragment.source.fullName;

    MethodElement2? findEncoderForElement(InterfaceElement2 element) {
      var candidates = element.methods2.where((m) => encoderChecker.firstAnnotationOfExact(m) != null);
      if (candidates.isEmpty) return null;
      if (candidates.length > 1) {
        log.severe(
            'Cannot have multiple methods annotated with @encoder in a single class. Failing element: ${element.name3} in $libName.');
      }
      var candidate = candidates.first;
      if (candidate.isPrivate) {
        log.severe(
            '@encoder cannot be used on private methods. Failing element: ${element.name3}.${candidate.name3}() in library $libName.');
        return null;
      }
      if (candidate.isStatic) {
        log.severe(
            '@encoder cannot be used on static methods. Failing element: ${element.name3}.${candidate.name3}() in library $libName.');
        return null;
      }
      if (candidate.formalParameters.isNotEmpty) {
        log.severe(
            'Methods annotated with @encoder must have no parameters. Failing element: ${element.name3}.${candidate.name3}() in library $libName.');
        return null;
      }
      return candidate;
    }

    ExecutableElement2? findDecoderForElement(InterfaceElement2 element) {
      var candidates = element.methods2
          .cast<ExecutableElement2>()
          .followedBy(element.constructors2)
          .where((m) => decoderChecker.firstAnnotationOfExact(m) != null);
      if (candidates.isEmpty) return null;
      if (candidates.length > 1) {
        log.severe(
            'Cannot have multiple members annotated with @decoder in a single class. Failing element: ${element.name3} in $libName.');
      }
      var candidate = candidates.first;
      if (candidate.isPrivate) {
        log.severe(
            '@decoder cannot be used on private members. Failing element: ${element.name3}.${candidate.name3}() in library $libName.');
        return null;
      }
      if (candidate is! ConstructorElement2 && !candidate.isStatic) {
        log.severe(
            '@decoder cannot be used on instance members. Failing element: ${element.name3}.${candidate.name3}() in library $libName.');
        return null;
      }
      if (candidate.formalParameters.length != 1) {
        log.severe(
            'Members annotated with @decoder must have exactly one parameter. Failing element: ${element.name3}.${candidate.name3}() in library $libName.');
        return null;
      }
      if (candidate.formalParameters.length != 1) {
        log.severe(
            'Members annotated with @decoder must have exactly one parameter. Failing element: ${element.name3}.${candidate.name3}() in library $libName.');
        return null;
      }
      if (candidate.returnType != element.thisType) {
        log.severe(
            'Members annotated with @decoder must return an instance of the target type. Failing element: ${element.name3}.${candidate.name3}() in library $libName.');
        return null;
      }
      return candidate;
    }

    var annotated = [...library.classes, ...library.extensionTypes]
        .map<(InterfaceElement2, ExecutableElement2, MethodElement2)?>((element) {
          var decoder = findDecoderForElement(element);
          var encoder = findEncoderForElement(element);

          if (decoder == null && encoder == null) {
            return null;
          } else if (decoder == null) {
            log.severe(
                'Elements defining an @encoder must also define a @decoder. Failing element: ${element.name3} in library $libName.');
            return null;
          } else if (encoder == null) {
            log.severe(
                'Elements defining a @decoder must also define an @encoder. Failing element: ${element.name3} in library $libName.');
            return null;
          }

          if (element.isPrivate) {
            log.severe(
                '@decoder and @encoder can only be used on public elements. Failing element: ${element.name3} in library $libName.');
            return null;
          }

          if (decoder.formalParameters.first.type != encoder.returnType) {
            log.severe(
                'The @decoder parameter type must match the @encoder return type. Failing element: ${element.name3} in library $libName.');
            return null;
          }

          if (element is ExtensionTypeElement2) {
            if (element.interfaces.firstOrNull != element.representation2.type) {
              log.severe(
                  'Extension types using @decoder and @encoder must implement the representation type. Failing element: ${element.name3} in library $libName.');
              return null;
            } else if (element.representation2.type.element?.name == null) {
              log.severe(
                  'Extension types using @decoder and @encoder must have a valid representation type. Failing element: ${element.name3} in library $libName.');
              return null;
            } else if (element.primaryConstructor2.isPrivate || (element.primaryConstructor2.name3 != 'new')) {
              log.severe(
                  'Extension types using @decoder and @encoder must have a public unnamed primary constructor. Failing element: ${element.name3} in library $libName.');
              return null;
            }
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
  final List<CodecElement> elements;

  CodecModule({required this.elements});

  factory CodecModule.fromElements(
      List<(InterfaceElement2, ExecutableElement2, MethodElement2)> elements, BuildStep buildStep) {
    return CodecModule(
      elements: [
        for (var (element, decoder, encoder) in elements) CodecElement.fromElement(element, decoder, encoder),
      ],
    );
  }

  factory CodecModule.deserialize(Map<String, dynamic> map) {
    return CodecModule(
      elements: [
        for (var e in map['elements']) CodecElement.deserialize(e),
      ],
    );
  }

  Map<String, dynamic> serialize() => {
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
  final String? typeImport;

  CodecElement({
    required this.name,
    this.extension,
    required this.decoder,
    required this.encoder,
    required this.import,
    this.typeImport,
  });

  factory CodecElement.fromElement(InterfaceElement2 element, ExecutableElement2 decoder, MethodElement2 encoder) {
    if (element is ExtensionTypeElement2) {
      var typeElement = element.representation2.type.element!;
      if (element.library2.exportNamespace.get(typeElement.name!) == typeElement) {
        return CodecElement(
          name: element.representation2.type.getDisplayString(),
          extension: element.name3,
          decoder: decoder.name3 ?? '',
          encoder: encoder.name3 ?? '',
          import: element.library2.firstFragment.source.uri.toString(),
        );
      } else {
        var import = element.library2.firstFragment.importedLibraries2
            .where((l) => l.exportNamespace.get(typeElement.name!) == typeElement)
            .firstOrNull;

        return CodecElement(
          name: element.representation2.type.getDisplayString(),
          extension: element.name3,
          decoder: decoder.name3 ?? '',
          encoder: encoder.name3 ?? '',
          import: element.library2.firstFragment.source.uri.toString(),
          typeImport: import?.firstFragment.source.uri.toString(),
        );
      }
    } else {
      return CodecElement(
        name: element.name3 ?? '',
        decoder: decoder.name3 ?? '',
        encoder: encoder.name3 ?? '',
        import: element.library2.firstFragment.source.uri.toString(),
      );
    }
  }

  CodecElement.deserialize(Map<String, dynamic> map)
      : name = map['name'],
        extension = map['extension'],
        decoder = map['decoder'],
        encoder = map['encoder'],
        import = map['import'],
        typeImport = map['typeImport'];

  Map<String, dynamic> serialize() => {
        'name': name,
        if (extension != null) 'extension': extension,
        'decoder': decoder,
        'encoder': encoder,
        'import': import,
        if (typeImport != null) 'typeImport': typeImport,
      };
}
