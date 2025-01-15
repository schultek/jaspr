part of '../styles.dart';

class _FlexBoxStyles extends Styles {
  final FlexDirection? direction;
  final FlexWrap? wrap;
  final JustifyContent? justifyContent;
  final AlignItems? alignItems;
  final Gap? gap;

  const _FlexBoxStyles({this.direction, this.wrap, this.justifyContent, this.alignItems, this.gap,}) : super._();

  @override
  Map<String, String> get styles => {
        'display': 'flex',
        if (direction != null) 'flex-direction': direction!.value,
        if (wrap != null) 'flex-wrap': wrap!.value,
        if (justifyContent != null) 'justify-content': justifyContent!.value,
        if (alignItems != null) 'align-items': alignItems!.value,
        ...?gap?.styles,
      };
}
