part of '../styles.dart';

class _GridItemStyles extends Styles {
  const _GridItemStyles({this.placement}) : super._();

  final GridPlacement? placement;

  @override
  Map<String, String> get styles => placement?.styles ?? {};
}
