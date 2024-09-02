import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:build/build.dart';
import 'package:jaspr/jaspr.dart';
import 'package:source_gen/source_gen.dart';

import '../utils.dart';
import 'codec_module_builder.dart';

final encoderChecker = TypeChecker.fromRuntime(EncoderAnnotation);
final decoderChecker = TypeChecker.fromRuntime(DecoderAnnotation);

typedef Codecs = Map<String, CodecElement>;

extension CodecLoader on BuildStep {
  Future<Codecs> loadCodecs() async {
    var bundle = await loadBundle<CodecElement>('codec', CodecElement.deserialize).toList();
    return {for (final c in bundle) c.name: c};
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
    var nullable = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
    var args = type.typeArguments.map((t) => t.accept(this));
    return '$name${args.isEmpty ? '' : '<${args.join(', ')}>'}$nullable';
  }
}
