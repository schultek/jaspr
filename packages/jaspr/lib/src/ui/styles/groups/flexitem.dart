part of style;

class _FlexItemStyles implements Styles {
  final Flex? flex;
  final int? order;
  final AlignSelf? alignSelf;

  const _FlexItemStyles({this.flex, this.order, this.alignSelf});

  @override
  Map<String, String> get styles => {
        ...?flex?.styles,
        if (order != null) 'order': order!.toString(),
        if (alignSelf != null) 'align-self': alignSelf!.value,
      };
}
