import '../../../foundation/constants.dart';
import 'unit.dart';

class GridTemplate {
  const GridTemplate({this.columns, this.rows, this.areas});

  final GridTracks? columns;
  final GridTracks? rows;
  final GridAreas? areas;

  Map<String, String> get styles {
    return {
      if (columns != null) 'grid-template-columns': columns!.value,
      if (rows != null) 'grid-template-rows': rows!.value,
      if (areas != null) 'grid-template-areas': areas!.value,
    };
  }
}

class GridTracks {
  /// Constructs a list of grid tracks.
  ///
  /// When using [GridTrack.line], must be alternated with value tracks.
  const factory GridTracks(List<GridTrack> tracks) = _GridTracks;

  const GridTracks._(this.value);

  static const GridTracks none = GridTracks._('none');

  final String value;
}

class _GridTracks implements GridTracks {
  const _GridTracks(this.tracks);

  final List<GridTrack> tracks;

  @override
  String get value => tracks.map((t) => t.value).join(' ');
}

class GridAreas {
  const GridAreas(this.lines);

  final List<String> lines;

  String get value => lines.map((l) => '"$l"').join(kDebugMode ? '\n' : ' ');
}

abstract class GridTrack {
  const factory GridTrack(TrackSize size) = _GridTrack;

  const factory GridTrack.line(String name) = _LineGridTrack;

  const factory GridTrack.repeat(TrackRepeat repeat, List<GridTrack> tracks) = _RepeatGridTrack;

  String get value;
}

class _LineGridTrack implements GridTrack {
  const _LineGridTrack(this.name);

  final String name;

  @override
  String get value => '[$name]';
}

class _GridTrack implements GridTrack {
  const _GridTrack(this.size);

  final TrackSize size;

  @override
  String get value => size.value;
}

class _RepeatGridTrack implements GridTrack {
  const _RepeatGridTrack(this.repeat, this.tracks);

  final TrackRepeat repeat;
  final List<GridTrack> tracks;

  @override
  String get value => 'repeat(${repeat.value}, ${tracks.map((t) => t.value).join(' ')})';
}

class TrackSize {
  const factory TrackSize(Unit value) = _TrackSize;

  const TrackSize._(this.value);

  const factory TrackSize.fr(double value) = _FrTrackSize;

  const factory TrackSize.minmax(TrackSize min, TrackSize max) = _MinMaxTrackSize;
  const factory TrackSize.fitContent(Unit value) = _FitContentTrackSize;

  static const TrackSize minContent = TrackSize._('min-content');
  static const TrackSize maxContent = TrackSize._('max-content');
  static const TrackSize auto = TrackSize._('auto');

  final String value;
}

class _TrackSize implements TrackSize {
  const _TrackSize(this._value);

  final Unit _value;

  @override
  String get value => _value.value;
}

class _FrTrackSize implements TrackSize {
  const _FrTrackSize(this._value);

  final double _value;

  @override
  String get value => '${_value}fr';
}

class _MinMaxTrackSize implements TrackSize {
  const _MinMaxTrackSize(this.min, this.max);

  final TrackSize min;
  final TrackSize max;

  @override
  String get value => 'minmax(${min.value}, ${max.value})';
}

class _FitContentTrackSize implements TrackSize {
  const _FitContentTrackSize(this._value);

  final Unit _value;

  @override
  String get value => 'fit-content(${_value.value})';
}

class TrackRepeat {
  const TrackRepeat(int times) : value = '$times';
  const TrackRepeat._(this.value);

  final String value;

  static const TrackRepeat autoFill = TrackRepeat._('auto-fill');
  static const TrackRepeat autoFit = TrackRepeat._('auto-fit');
}

class GridGap {
  const GridGap({this.row, this.column});

  const GridGap.all(Unit value)
      : row = value,
        column = value;

  final Unit? row;
  final Unit? column;

  Map<String, String> get styles {
    if (row != null && row == column) {
      return {'gap': row!.value};
    } else if (row != null && column != null) {
      return {'gap': '${row!.value} ${column!.value}'};
    } else {
      return {
        if (row != null) 'row-gap': row!.value,
        if (column != null) 'column-gap': column!.value,
      };
    }
  }
}
