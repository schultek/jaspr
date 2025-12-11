import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:build/build.dart';
import 'package:jaspr/jaspr.dart';
import 'package:source_gen/source_gen.dart';

import '../utils.dart';
import 'codec_module_builder.dart';

final encoderChecker = TypeChecker.typeNamed(EncoderAnnotation, inPackage: 'jaspr');
final decoderChecker = TypeChecker.typeNamed(DecoderAnnotation, inPackage: 'jaspr');

typedef Codecs = Map<String, CodecElement>;

extension CodecLoader on BuildStep {
  Future<Codecs> loadCodecs() async {
    final bundle = await loadBundle<CodecElement>('codec', CodecElement.deserialize).toList();
    return {for (final c in bundle) c.name: c};
  }
}

extension CodecReader on Codecs {
  String getDecoderFor(DartType type, String getter, bool allowComponent) {
    final decoder = type.acceptWithArgument(DecoderVisitor(this, allowComponent), getter);
    return decoder.decoder.replaceAll('__CAST__', decoder.cast);
  }

  String getEncoderFor(DartType type, String getter) {
    final encoder = type.acceptWithArgument(EncoderVisitor(this), getter);
    return encoder ?? getter;
  }

  String getPrefixedType(DartType type) {
    return type.accept(PrefixVisitor(this));
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
      final nested = type.typeArguments.first.acceptWithArgument(this, 'i');
      if (nested != null) {
        final nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return '$argument$nullCheck.map((i) => $nested).toList()';
      }
    } else if (type.isDartCoreMap && type.typeArguments[0].isDartCoreString) {
      final nested = type.typeArguments[1].acceptWithArgument(this, 'v');
      if (nested != null) {
        final nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
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
        final nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
        return '$argument$nullCheck.${codec.encoder}()';
      }
    }
    return super.visitInterfaceType(type, argument);
  }
}

typedef DecoderResult = ({
  String decoder,
  String cast,
});

class DecoderVisitor extends UnifyingTypeVisitorWithArgument<DecoderResult, String> {
  DecoderVisitor(this.codecs, this.allowComponent);

  final Codecs codecs;
  final bool allowComponent;

  @override
  DecoderResult visitDartType(DartType type, String argument) {
    if (!type.isDartPrimitive) {
      throw const InvalidParameterException();
    }
    return (decoder: argument, cast: type.getDisplayString());
  }

  @override
  DecoderResult visitInterfaceType(InterfaceType type, String argument) {
    if (type.isDartCoreList) {
      final nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
      if (type.typeArguments.first
          case DynamicType() || DartType(isDartCoreObject: true, nullabilitySuffix: NullabilitySuffix.question)) {
        return (decoder: argument, cast: 'List<Object?>$nullCheck');
      }
      final nested = type.typeArguments.first.acceptWithArgument(this, 'i');
      final nestedNullCheck =
          !nested.cast.endsWith('?') && type.typeArguments.first.nullabilitySuffix == NullabilitySuffix.question
          ? '?'
          : '';
      var decoder = argument.endsWith(' as __CAST__') ? '($argument)$nullCheck' : '$argument$nullCheck';
      decoder += '.cast<${nested.cast}$nestedNullCheck>()';
      if (nested.decoder != 'i') {
        decoder += '.map((i) => ${nested.decoder}).toList()';
      }
      return (decoder: decoder, cast: 'List<Object?>$nullCheck');
    } else if (type.isDartCoreMap) {
      if (!type.typeArguments.first.isDartCoreString) {
        throw const InvalidParameterException();
      }

      final nullCheck = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
      if (type.typeArguments[1]
          case DynamicType() || DartType(isDartCoreObject: true, nullabilitySuffix: NullabilitySuffix.question)) {
        return (decoder: argument, cast: 'Map<String, Object?>$nullCheck');
      }
      final nested = type.typeArguments[1].acceptWithArgument(this, 'v');
      final nestedNullCheck =
          !nested.cast.endsWith('?') && type.typeArguments[1].nullabilitySuffix == NullabilitySuffix.question
          ? '?'
          : '';
      var decoder = argument.endsWith(' as __CAST__') ? '($argument)$nullCheck' : '$argument$nullCheck';
      decoder += '.cast<String, ${nested.cast}$nestedNullCheck>()';
      if (nested.decoder != 'v') {
        decoder += '.map((k, v) => MapEntry(k, ${nested.decoder}))';
      }
      return (decoder: decoder, cast: 'Map<String, Object?>$nullCheck');
    } else if (codecs[type.element.name] case final codec?) {
      final decoderCall = '[[${codec.import}]].${codec.extension ?? codec.name}.${codec.decoder}';
      final argRaw = argument.endsWith(' as __CAST__')
          ? argument.substring(0, argument.length - ' as __CAST__'.length)
          : argument;

      final decoder = type.nullabilitySuffix == NullabilitySuffix.question
          ? '$argRaw != null ? $decoderCall($argument) : null'
          : '$decoderCall($argument)';

      return (decoder: decoder, cast: codec.rawType);
    } else if (allowComponent &&
        type.element.name == 'Component' &&
        type.element.library.identifier == 'package:jaspr/src/framework/framework.dart') {
      return (decoder: 'p.mount($argument)', cast: 'String');
    }
    return super.visitInterfaceType(type, argument);
  }
}

class PrefixVisitor extends UnifyingTypeVisitor<String> {
  PrefixVisitor(this.codecs);
  final Codecs codecs;

  @override
  String visitDartType(DartType type) {
    return type.getDisplayString();
  }

  @override
  String visitInterfaceType(InterfaceType type) {
    var name = type.element.name;
    if (codecs[type.element.name] case final codec?) {
      name = '[[${codec.typeImport ?? codec.import}]].$name';
    }
    final nullable = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
    final args = type.typeArguments.map((t) => t.accept(this));
    return '$name${args.isEmpty ? '' : '<${args.join(', ')}>'}$nullable';
  }
}

extension on DartType {
  bool get isDartPrimitive {
    return isDartCoreString ||
        isDartCoreBool ||
        isDartCoreDouble ||
        isDartCoreInt ||
        isDartCoreNum ||
        isDartCoreNull ||
        isDartCoreObject ||
        (isDartCoreList && (this as InterfaceType).typeArguments.first is DynamicType) ||
        (isDartCoreMap &&
            (this as InterfaceType).typeArguments.first.isDartCoreString &&
            (this as InterfaceType).typeArguments.last is DynamicType);
  }
}

class InvalidParameterException implements Exception {
  const InvalidParameterException();
}
