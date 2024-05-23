/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class QuoteInit extends _i1.SerializableEntity {
  QuoteInit._({required this.id});

  factory QuoteInit({required int id}) = _QuoteInitImpl;

  factory QuoteInit.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return QuoteInit(
        id: serializationManager.deserialize<int>(jsonSerialization['id']));
  }

  int id;

  QuoteInit copyWith({int? id});
  @override
  Map<String, dynamic> toJson() {
    return {'id': id};
  }

  @override
  Map<String, dynamic> allToJson() {
    return {'id': id};
  }
}

class _QuoteInitImpl extends QuoteInit {
  _QuoteInitImpl({required int id}) : super._(id: id);

  @override
  QuoteInit copyWith({int? id}) {
    return QuoteInit(id: id ?? this.id);
  }
}
