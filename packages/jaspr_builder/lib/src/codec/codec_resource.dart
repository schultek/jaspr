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
  (String, Set<String>) getDecoderFor(DartType type, String getter) {
    var decoder = type.acceptWithArgument(DecoderVisitor(this), getter);

    if (decoder.$1 == null) {
      return (getter, <String>{});
    }

    return (decoder.$1!, decoder.$2);
  }

  (String, Set<String>) getEncoderFor(DartType type, String getter) {
    var encoder = type.acceptWithArgument(EncoderVisitor(this), getter);

    if (encoder.$1 == null) {
      return (getter, <String>{});
    }

    return (encoder.$1!, encoder.$2);
  }
}

typedef VisitorResult = (String?, Set<String>);

class EncoderVisitor extends UnifyingTypeVisitorWithArgument<VisitorResult, String> {
  EncoderVisitor(this.codecs);
  final Codecs codecs;

  @override
  VisitorResult visitDartType(DartType type, String argument) {
    return (null, {});
  }

  @override
  VisitorResult visitInterfaceType(InterfaceType type, String argument, [bool checkNullability = true]) {
    if (type.isDartCoreList) {
      var nested = type.typeArguments.first.acceptWithArgument(this, 'i');
      if (nested.$1 != null) {
        var nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return ('$argument$nullCheck.map((i) => ${nested.$1}).toList()', nested.$2);
      }
    } else if (type.isDartCoreMap && type.typeArguments[0].isDartCoreString) {
      var nested = type.typeArguments[1].acceptWithArgument(this, 'v');
      if (nested.$1 != null) {
        var nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return ('$argument$nullCheck.map((k, v) => MapEntry(k, ${nested.$1}))', nested.$2);
      }
    } else if (codecs[type.element.name] case final codec?) {
      if (codec.extension != null) {
        if (type.nullabilitySuffix == NullabilitySuffix.question) {
          return ('$argument != null ? ${codec.extension}($argument!).${codec.encoder}() : null', {codec.import});
        } else {
          return ('${codec.extension}($argument).${codec.encoder}()', {codec.import});
        }
      } else {
        var nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return ('$argument$nullCheck.${codec.encoder}()', {codec.import});
      }
    }
    return super.visitInterfaceType(type, argument);
  }
}

class DecoderVisitor extends UnifyingTypeVisitorWithArgument<VisitorResult, String> {
  DecoderVisitor(this.codecs);
  final Codecs codecs;

  @override
  VisitorResult visitDartType(DartType type, String argument) {
    return (null, {});
  }

  @override
  VisitorResult visitInterfaceType(InterfaceType type, String argument) {
    if (type.isDartCoreList) {
      var nested = type.typeArguments.first.acceptWithArgument(this, 'i');
      if (nested.$1 != null) {
        var nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return ('($argument as List<dynamic>$nullCheck)$nullCheck.map((i) => ${nested.$1}).toList()', nested.$2);
      }
    } else if (type.isDartCoreMap) {
      var nested = type.typeArguments[1].acceptWithArgument(this, 'v');
      if (nested.$1 != null) {
        var nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return (
          '($argument as Map<String, dynamic>$nullCheck)$nullCheck.map((k, v) => MapEntry(k, ${nested.$1}))',
          nested.$2
        );
      }
    } else if (codecs[type.element.name] case final codec?) {
      if (type.nullabilitySuffix == NullabilitySuffix.question) {
        return (
          '$argument != null ? ${codec.extension ?? codec.name}.${codec.decoder}($argument!) : null',
          {codec.import}
        );
      } else {
        return ('${codec.extension ?? codec.name}.${codec.decoder}($argument)', {codec.import});
      }
    }
    return super.visitInterfaceType(type, argument);
  }
}
