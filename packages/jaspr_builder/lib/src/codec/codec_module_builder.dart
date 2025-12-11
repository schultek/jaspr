import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
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
    '.dart': ['.codec.json'],
  };

  Future<void> generateCodecModule(BuildStep buildStep) async {
    // Performance optimization
    final file = await buildStep.readAsString(buildStep.inputId);
    if (!file.contains('@decoder') && !file.contains('@encoder')) {
      return;
    }

    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    final library = await buildStep.inputLibrary;
    final libName = library.firstFragment.source.fullName;

    MethodElement? findEncoderForElement(InterfaceElement element) {
      final candidates = element.methods.where((m) => encoderChecker.firstAnnotationOfExact(m) != null);
      if (candidates.isEmpty) return null;
      if (candidates.length > 1) {
        log.severe(
          'Cannot have multiple methods annotated with @encoder in a single class. Failing element: ${element.name} in $libName.',
        );
      }
      final candidate = candidates.first;
      if (candidate.isPrivate) {
        log.severe(
          '@encoder cannot be used on private methods. Failing element: ${element.name}.${candidate.name}() in library $libName.',
        );
        return null;
      }
      if (candidate.isStatic) {
        log.severe(
          '@encoder cannot be used on static methods. Failing element: ${element.name}.${candidate.name}() in library $libName.',
        );
        return null;
      }
      if (candidate.formalParameters.isNotEmpty) {
        log.severe(
          'Methods annotated with @encoder must have no parameters. Failing element: ${element.name}.${candidate.name}() in library $libName.',
        );
        return null;
      }
      return candidate;
    }

    ExecutableElement? findDecoderForElement(InterfaceElement element) {
      final candidates = element.methods
          .cast<ExecutableElement>()
          .followedBy(element.constructors)
          .where((m) => decoderChecker.firstAnnotationOfExact(m) != null);
      if (candidates.isEmpty) return null;
      if (candidates.length > 1) {
        log.severe(
          'Cannot have multiple members annotated with @decoder in a single class. Failing element: ${element.name} in $libName.',
        );
      }
      final candidate = candidates.first;
      if (candidate.isPrivate) {
        log.severe(
          '@decoder cannot be used on private members. Failing element: ${element.name}.${candidate.name}() in library $libName.',
        );
        return null;
      }
      if (candidate is! ConstructorElement && !candidate.isStatic) {
        log.severe(
          '@decoder cannot be used on instance members. Failing element: ${element.name}.${candidate.name}() in library $libName.',
        );
        return null;
      }
      if (candidate.formalParameters.length != 1) {
        log.severe(
          'Members annotated with @decoder must have exactly one parameter. Failing element: ${element.name}.${candidate.name}() in library $libName.',
        );
        return null;
      }
      if (candidate.formalParameters.length != 1) {
        log.severe(
          'Members annotated with @decoder must have exactly one parameter. Failing element: ${element.name}.${candidate.name}() in library $libName.',
        );
        return null;
      }
      if (candidate.returnType != element.thisType) {
        log.severe(
          'Members annotated with @decoder must return an instance of the target type. Failing element: ${element.name}.${candidate.name}() in library $libName.',
        );
        return null;
      }
      return candidate;
    }

    final annotated = [...library.classes, ...library.extensionTypes]
        .map<(InterfaceElement, ExecutableElement, MethodElement)?>((element) {
          final decoder = findDecoderForElement(element);
          final encoder = findEncoderForElement(element);

          if (decoder == null && encoder == null) {
            return null;
          } else if (decoder == null) {
            log.severe(
              'Elements defining an @encoder must also define a @decoder. Failing element: ${element.name} in library $libName.',
            );
            return null;
          } else if (encoder == null) {
            log.severe(
              'Elements defining a @decoder must also define an @encoder. Failing element: ${element.name} in library $libName.',
            );
            return null;
          }

          if (element.isPrivate) {
            log.severe(
              '@decoder and @encoder can only be used on public elements. Failing element: ${element.name} in library $libName.',
            );
            return null;
          }

          if (decoder.formalParameters.first.type != encoder.returnType) {
            log.severe(
              'The @decoder parameter type must match the @encoder return type. Failing element: ${element.name} in library $libName.',
            );
            return null;
          }

          if (element is ExtensionTypeElement) {
            if (element.interfaces.firstOrNull != element.representation.type) {
              log.severe(
                'Extension types using @decoder and @encoder must implement the representation type. Failing element: ${element.name} in library $libName.',
              );
              return null;
            } else if (element.representation.type.element?.name == null) {
              log.severe(
                'Extension types using @decoder and @encoder must have a valid representation type. Failing element: ${element.name} in library $libName.',
              );
              return null;
            } else if (element.primaryConstructor.isPrivate || (element.primaryConstructor.name != 'new')) {
              log.severe(
                'Extension types using @decoder and @encoder must have a public unnamed primary constructor. Failing element: ${element.name} in library $libName.',
              );
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

    final module = CodecModule.fromElements(annotated, buildStep);

    final outputId = buildStep.inputId.changeExtension('.codec.json');
    await buildStep.writeAsString(outputId, jsonEncode(module.serialize()));
  }
}

class CodecModule {
  final List<CodecElement> elements;

  CodecModule({required this.elements});

  factory CodecModule.fromElements(
    List<(InterfaceElement, ExecutableElement, MethodElement)> elements,
    BuildStep buildStep,
  ) {
    return CodecModule(
      elements: [
        for (final (element, decoder, encoder) in elements) CodecElement.fromElement(element, decoder, encoder),
      ],
    );
  }

  factory CodecModule.deserialize(Map<String, Object?> map) {
    return CodecModule(
      elements: [for (final e in map['elements'] as List<Object?>) CodecElement.deserialize(e as Map<String, Object?>)],
    );
  }

  Map<String, Object?> serialize() => {
    'elements': [for (final e in elements) e.serialize()],
  };
}

class CodecElement {
  final String name;
  final String? extension;
  final String decoder;
  final String encoder;
  final String rawType;
  final String import;
  final String? typeImport;

  CodecElement({
    required this.name,
    this.extension,
    required this.decoder,
    required this.encoder,
    required this.rawType,
    required this.import,
    this.typeImport,
  });

  factory CodecElement.fromElement(InterfaceElement element, ExecutableElement decoder, MethodElement encoder) {
    if (element is ExtensionTypeElement) {
      final typeElement = element.representation.type.element!;
      if (element.library.exportNamespace.get2(typeElement.name!) == typeElement) {
        return CodecElement(
          name: element.representation.type.getDisplayString(),
          extension: element.name,
          decoder: decoder.name ?? '',
          encoder: encoder.name ?? '',
          rawType: encoder.returnType.getDisplayString(),
          import: element.library.firstFragment.source.uri.toString(),
        );
      } else {
        final import = element.library.firstFragment.importedLibraries
            .where((l) => l.exportNamespace.get2(typeElement.name!) == typeElement)
            .firstOrNull;

        return CodecElement(
          name: element.representation.type.getDisplayString(),
          extension: element.name,
          decoder: decoder.name ?? '',
          encoder: encoder.name ?? '',
          rawType: encoder.returnType.getDisplayString(),
          import: element.library.firstFragment.source.uri.toString(),
          typeImport: import?.firstFragment.source.uri.toString(),
        );
      }
    } else {
      return CodecElement(
        name: element.name ?? '',
        decoder: decoder.name ?? '',
        encoder: encoder.name ?? '',
        rawType: encoder.returnType.getDisplayString(),
        import: element.library.firstFragment.source.uri.toString(),
      );
    }
  }

  CodecElement.deserialize(Map<String, Object?> map)
    : name = map['name'] as String,
      extension = map['extension'] as String?,
      decoder = map['decoder'] as String,
      encoder = map['encoder'] as String,
      rawType = map['rawType'] as String,
      import = map['import'] as String,
      typeImport = map['typeImport'] as String?;

  Map<String, Object?> serialize() => {
    'name': name,
    'extension': ?extension,
    'decoder': decoder,
    'encoder': encoder,
    'rawType': rawType,
    'import': import,
    'typeImport': ?typeImport,
  };
}
