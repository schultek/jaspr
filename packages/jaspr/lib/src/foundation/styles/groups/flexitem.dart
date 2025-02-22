part of '../styles.dart';

class _FlexItemStyles extends Styles {
  final Flex? flex;
  final int? order;
  final AlignSelf? alignSelf;

  const _FlexItemStyles({this.flex, this.order, this.alignSelf}) : super._();

  @override
  Map<String, String> get properties => {
        ...?flex?.styles,
        if (order != null) 'order': order!.toString(),
        if (alignSelf != null) 'align-self': alignSelf!.value,
      };
}
