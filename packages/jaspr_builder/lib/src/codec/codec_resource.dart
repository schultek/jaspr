import 'dart:convert';

import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:jaspr/jaspr.dart';
import 'package:source_gen/source_gen.dart';

import 'codec_module_builder.dart';

final codecResource = Resource<CodecResource>(() => CodecResource._());

final encoderChecker = TypeChecker.fromRuntime(EncoderAnnotation);
final decoderChecker = TypeChecker.fromRuntime(DecoderAnnotation);

typedef Codecs = Map<String, CodecElement>;

class CodecResource {
  CodecResource._();

  Future<Codecs>? _codecs;

  Future<Codecs> readCodecs(AssetReader reader) async {
    return _codecs ??= Future(() async {
      var modules = reader
          .findAssets(Glob('lib/**.codec.json'))
          .asyncMap((id) => reader.readAsString(id))
          .map((c) => CodecModule.deserialize(jsonDecode(c)));
      var codecs = <String, CodecElement>{};
      await for (final module in modules) {
        for (var element in module.elements) {
          codecs[element.name] = element;
        }
      }
      return codecs;
    });
  }
}

extension CodecReader on Codecs {
  String getDecoderFor(DartType type, String getter) {
    var decoder = type.acceptWithArgument(DecoderVisitor(this), getter);
    return decoder ?? getter;
  }

  String getEncoderFor(DartType type, String getter) {
    var encoder = type.acceptWithArgument(EncoderVisitor(this), getter);
    return encoder ?? getter;
  }
}

class EncoderVisitor extends UnifyingTypeVisitorWithArgument<String?, String> {
  EncoderVisitor(this.codecs);
  final Codecs codecs;

  @override
  String? visitDartType(DartType type, String argument) {
    return null;
  }

  @override
  String? visitInterfaceType(InterfaceType type, String argument, [bool checkNullability = true]) {
    if (type.isDartCoreList) {
      var nested = type.typeArguments.first.acceptWithArgument(this, 'i');
      if (nested != null) {
        var nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return '$argument$nullCheck.map((i) => $nested).toList()';
      }
    } else if (type.isDartCoreMap && type.typeArguments[0].isDartCoreString) {
      var nested = type.typeArguments[1].acceptWithArgument(this, 'v');
      if (nested != null) {
        var nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return '$argument$nullCheck.map((k, v) => MapEntry(k, $nested))';
      }
    } else if (codecs[type.element.name] case final codec?) {
      if (codec.extension != null) {
        if (type.nullabilitySuffix == NullabilitySuffix.question) {
          return '$argument != null ? [[${codec.import}]].${codec.extension}($argument!).${codec.encoder}() : null';
        } else {
          return '[[${codec.import}]].${codec.extension}($argument).${codec.encoder}()';
        }
      } else {
        var nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return '$argument$nullCheck.${codec.encoder}()';
      }
    }
    return super.visitInterfaceType(type, argument);
  }
}

class DecoderVisitor extends UnifyingTypeVisitorWithArgument<String?, String> {
  DecoderVisitor(this.codecs);
  final Codecs codecs;

  @override
  String? visitDartType(DartType type, String argument) {
    return null;
  }

  @override
  String? visitInterfaceType(InterfaceType type, String argument) {
    if (type.isDartCoreList) {
      var nested = type.typeArguments.first.acceptWithArgument(this, 'i');
      if (nested != null) {
        var nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return '($argument as List<dynamic>$nullCheck)$nullCheck.map((i) => $nested).toList()';
      }
    } else if (type.isDartCoreMap) {
      var nested = type.typeArguments[1].acceptWithArgument(this, 'v');
      if (nested != null) {
        var nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return '($argument as Map<String, dynamic>$nullCheck)$nullCheck.map((k, v) => MapEntry(k, $nested))';
      }
    } else if (codecs[type.element.name] case final codec?) {
      if (type.nullabilitySuffix == NullabilitySuffix.question) {
        return '$argument != null ? [[${codec.import}]].${codec.extension ?? codec.name}.${codec.decoder}($argument!) : null';
      } else {
        return '[[${codec.import}]].${codec.extension ?? codec.name}.${codec.decoder}($argument)';
      }
    }
    return super.visitInterfaceType(type, argument);
  }
}
