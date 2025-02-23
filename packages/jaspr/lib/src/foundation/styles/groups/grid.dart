part of '../styles.dart';

class _GridStyles extends Styles {
  const _GridStyles({this.template, this.gap, this.autoRows, this.autoColumns}) : super._();

  final GridTemplate? template;
  final Gap? gap;
  final List<TrackSize>? autoRows;
  final List<TrackSize>? autoColumns;

  @override
  Map<String, String> get properties => {
        'display': 'grid',
        ...?template?.styles,
        if (autoRows != null) 'grid-auto-rows': autoRows!.map((s) => s.value).join(' '),
        if (autoColumns != null) 'grid-auto-columns': autoColumns!.map((s) => s.value).join(' '),
        ...?gap?.styles,
      };
}
