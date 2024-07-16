abstract class GridPlacement {
  const factory GridPlacement(
      {LinePlacement? rowStart,
      LinePlacement? rowEnd,
      LinePlacement? columnStart,
      LinePlacement? columnEnd}) = _LineGridPlacement;

  const factory GridPlacement.area(String name) = _GridPlacement;

  static const GridPlacement auto = _GridPlacement('auto');

  Map<String, String> get styles;
}

class _GridPlacement implements GridPlacement {
  const _GridPlacement(this.value);

  final String value;

  @override
  Map<String, String> get styles => {'grid-area': value};
}

class _LineGridPlacement implements GridPlacement {
  const _LineGridPlacement({this.rowStart, this.rowEnd, this.columnStart, this.columnEnd});

  final LinePlacement? rowStart;
  final LinePlacement? rowEnd;
  final LinePlacement? columnStart;
  final LinePlacement? columnEnd;

  @override
  Map<String, String> get styles {
    if (rowStart != null && columnStart != null && (rowEnd != null || columnEnd == null)) {
      return {
        'grid-area': [
          rowStart!.value,
          columnStart!.value,
          if (rowEnd != null) rowEnd!.value,
          if (columnEnd != null) columnEnd!.value
        ].join(' / '),
      };
    } else {
      return {
        if (rowStart != null)
          'grid-row': [rowStart!.value, if (rowEnd != null) rowEnd!.value].join(' / ')
        else if (rowEnd != null)
          'grid-row-end': rowEnd!.value,
        if (columnStart != null)
          'grid-column': [columnStart!.value, if (columnEnd != null) columnEnd!.value].join(' / ')
        else if (columnEnd != null)
          'grid-column-end': columnEnd!.value,
      };
    }
  }
}

class LinePlacement {
  const factory LinePlacement(int index, {String? lineName}) = _NormalLinePlacement;

  const LinePlacement._(this.value);

  const factory LinePlacement.named(String name) = _NamedLinePlacement;

  const factory LinePlacement.span(int span, {String? lineName}) = _SpanLinePlacement;

  static const LinePlacement auto = LinePlacement._('auto');

  final String value;
}

class _LinePlacement implements LinePlacement {
  const _LinePlacement({this.number, this.span = false, this.lineName});

  final int? number;
  final bool span;
  final String? lineName;

  @override
  String get value => [if (span) 'span', if (number != null) number, if (lineName != null) lineName].join(' ');
}

class _NamedLinePlacement extends _LinePlacement {
  const _NamedLinePlacement(String name) : super(lineName: name);
}

class _NormalLinePlacement extends _LinePlacement {
  const _NormalLinePlacement(int index, {super.lineName}) : super(number: index);
}

class _SpanLinePlacement extends _LinePlacement {
  const _SpanLinePlacement(int span, {super.lineName}) : super(span: true, number: span);
}
