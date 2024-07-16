part of '../styles.dart';

class _FlexItemStyles extends Styles {
  const _FlexItemStyles({this.flex, this.order, this.alignSelf}) : super._();

  final Flex? flex;
  final int? order;
  final AlignSelf? alignSelf;

  @override
  Map<String, String> get styles => {
        ...?flex?.styles,
        if (order != null) 'order': order!.toString(),
        if (alignSelf != null) 'align-self': alignSelf!.value,
      };
}
