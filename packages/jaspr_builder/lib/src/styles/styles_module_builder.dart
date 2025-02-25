import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';

import '../utils.dart';

/// Builds modules for components annotated with @styles
class StylesModuleBuilder implements Builder {
  StylesModuleBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateStylesModule(buildStep);
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
        'lib/{{file}}.dart': ['lib/{{file}}.styles.json'],
      };

  Future<void> generateStylesModule(BuildStep buildStep) async {
    // Performance optimization
    var file = await buildStep.readAsString(buildStep.inputId);
    if (!file.contains('@css')) {
      return;
    }

    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    var library = await buildStep.inputLibrary;

    var annotated = library.topLevelElements
        .expand<Element>((e) {
          if (e is ClassElement) {
            return [...e.accessors.where((a) => a.isGetter), ...e.fields];
          } else if (e is PropertyAccessorElement && e.isGetter) {
            return [e];
          } else if (e is TopLevelVariableElement) {
            return [e];
          } else {
            return [];
          }
        })
        .where((element) => stylesChecker.firstAnnotationOfExact(element) != null)
        .where((element) {
          if (element.enclosingElement3 case ClassElement clazz when clazz.isPrivate || element.isPrivate) {
            log.severe(
                '@css cannot be used on private classes or members. Failing element: ${clazz.name}.${element.name} in library ${library.source.fullName}.');
            return false;
          } else if (element.enclosingElement3 case ClassElement clazz
              when (element is FieldElement && !element.isStatic) ||
                  (element is PropertyAccessorElement && !element.isStatic)) {
            log.severe(
                '@css cannot be used on non-static class members. Failing element: ${clazz.name}.${element.name} in library ${library.source.fullName}.');
            return false;
          } else if (element.isPrivate) {
            log.severe(
                '@css cannot be used on private variables or getters. Failing element: ${element.name} in library ${library.source.fullName}.');
            return false;
          }

          final type = switch (element) {
            PropertyAccessorElement e => e.type.returnType,
            PropertyInducingElement e => e.type,
            _ => null,
          };

          if (type == null ||
              !type.isDartCoreList ||
              !styleRuleChecker.isAssignableFromType((type as InterfaceType).typeArguments.first)) {
            final prefix = switch (element.enclosingElement3) { ClassElement(:var name) => '$name.', _ => '' };
            log.severe(
                '@css can only be applied on variables or getters of type List<StyleRule>. Failing element: $prefix${element.name} with type $type in library ${element.source?.fullName}.');
            return false;
          }

          return true;
        })
        .map((e) {
          if (e.enclosingElement3 case ClassElement clazz) {
            return '${clazz.name}.${e.name}';
          } else {
            return e.name;
          }
        })
        .whereType<String>()
        .toList()
      ..sort();

    if (annotated.isEmpty) {
      return;
    }

    var module = StylesModule(elements: annotated, id: buildStep.inputId);

    var outputId = buildStep.inputId.changeExtension('.styles.json');
    await buildStep.writeAsString(outputId, jsonEncode(module.serialize()));
  }
}

class StylesModule {
  final List<String> elements;
  final AssetId id;

  StylesModule({required this.elements, required this.id});

  factory StylesModule.deserialize(Map<String, dynamic> map) {
    return StylesModule(
      elements: (map['elements'] as List).cast<String>(),
      id: AssetId.deserialize(map['id']),
    );
  }

  Map<String, dynamic> serialize() => {
        'elements': elements,
        'id': id.serialize(),
      };
}
