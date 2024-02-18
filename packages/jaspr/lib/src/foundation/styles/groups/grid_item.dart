part of '../styles.dart';

class _GridItemStyles implements Styles {
  const _GridItemStyles({this.placement});

  final GridPlacement? placement;

  @override
  Map<String, String> get styles => placement?.styles ?? {};
}
