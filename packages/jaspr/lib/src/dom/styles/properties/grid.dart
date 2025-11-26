import '../../../foundation/constants.dart';
import 'unit.dart';

/// The `grid-template` CSS property defines grid columns, grid rows, and grid areas.
///
/// - A grid column is a vertical track in a CSS grid layout, and is the space between two vertical grid lines.
/// - A grid row is a horizontal track in a CSS grid layout, that is the space between two horizontal grid lines.
/// - A grid area is one or more grid cells that make up a rectangular area on the grid.
///
/// Read more: [MDN CSS Grid Layout](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_grid_layout)
class GridTemplate {
  const GridTemplate({this.columns, this.rows, this.areas});

  final GridTracks? columns;
  final GridTracks? rows;
  final GridAreas? areas;

  Map<String, String> get styles {
    return {
      'grid-template-columns': ?columns?.value,
      'grid-template-rows': ?rows?.value,
      'grid-template-areas': ?areas?.value,
    };
  }
}

/// Represents a list of grid tracks for rows or columns.
///
/// Use [GridTracks.none] to specify no tracks.
///
/// When constructing with a list of [GridTrack]s, use [GridTrack.line] to define named lines,
/// and alternate with size tracks defined using [TrackSize] or other [GridTrack] constructors.
///
/// Example:
/// ```dart
/// GridTracks([
///   GridTrack.line('header'),
///   GridTrack(TrackSize(16.rem)),
///   GridTrack.line('content-start'),
///   GridTrack(TrackSize.fr(1)),
///   GridTrack.line('content-end'),
///   GridTrack(TrackSize.auto),
///   GridTrack.line('footer'),
/// ]),
/// ```
///
/// Read more: [MDN Grid Tracks](https://developer.mozilla.org/en-US/docs/Glossary/Grid_Tracks)
class GridTracks {
  const GridTracks._(this.value);

  final String value;

  static const GridTracks none = GridTracks._('none');

  /// Constructs a list of grid tracks.
  ///
  /// When using [GridTrack.line], must be alternated with value tracks.
  const factory GridTracks(List<GridTrack> tracks) = _GridTracks;
}

class _GridTracks implements GridTracks {
  const _GridTracks(this.tracks);

  final List<GridTrack> tracks;

  bool _validateTracks() {
    if (tracks.isEmpty) {
      throw 'GridTracks cannot be empty';
    }
    return true;
  }

  @override
  String get value {
    assert(_validateTracks());
    return tracks.map((t) => t.value).join(' ');
  }
}

/// Represents the grid areas defined in a grid layout.
///
/// Each string in [lines] represents a row in the grid, with area names separated by spaces.
/// Use `.` to represent empty cells.
///
/// Example:
/// ```dart
/// GridAreas([
///   'header header header',
///   'sidebar content content',
///   'footer footer footer',
/// ])/// ```
///
/// This defines a grid with three rows and three columns, where:
/// - The first row has a single area named 'header' spanning all three columns.
/// - The second row has two areas: 'sidebar' in the first column and 'content' spanning the second and third columns.
/// - The third row has a single area named 'footer' spanning all three columns.
///
/// Read more: [MDN Grid Areas](https://developer.mozilla.org/en-US/docs/Glossary/Grid_Areas)
class GridAreas {
  const GridAreas(this.lines);

  final List<String> lines;

  bool _validateAreas() {
    if (lines.isEmpty) {
      throw 'GridAreas cannot be empty';
    }
    return true;
  }

  String get value {
    assert(_validateAreas());
    return lines.map((l) => '"$l"').join(kDebugMode ? '\n' : ' ');
  }
}

/// Represents a single track in a grid layout, which can be a line, a size, or a repeated set of tracks.
abstract class GridTrack {
  /// Creates a named grid line.
  const factory GridTrack.line(String name) = _LineGridTrack;

  /// Creates a grid track with the specified [size].
  const factory GridTrack(TrackSize size) = _GridTrack;

  /// Creates a repeated set of grid tracks.
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

/// Represents the size of a grid track in a grid layout.
///
/// Use the static members to create different types of track sizes:
/// - [TrackSize] for fixed sizes using [Unit]s.
/// - [TrackSize.fr] for fractional sizes.
/// - [TrackSize.minmax] for specifying minimum and maximum sizes.
/// - [TrackSize.fitContent] for fitting content within a specified size.
/// - [TrackSize.minContent] for minimum content size.
/// - [TrackSize.maxContent] for maximum content size.
/// - [TrackSize.auto] for automatic sizing.
///
/// Read more: [MDN Grid Tracks](https://developer.mozilla.org/en-US/docs/Glossary/Grid_Tracks)
class TrackSize {
  const TrackSize._(this.value);

  final String value;

  /// Creates a track size with a fixed [value].
  const factory TrackSize(Unit value) = _TrackSize;

  /// Creates a track size that is a fraction of the available space.
  const factory TrackSize.fr(double value) = _FrTrackSize;

  /// Creates a track size that defines a size range greater than or equal to [min] and less than or equal to [max].
  /// If max is smaller than min, then max is ignored and the function is treated as min. As a maximum, a flex value
  /// sets the track's flex factor. It is invalid as a minimum.
  const factory TrackSize.minmax(TrackSize min, TrackSize max) = _MinMaxTrackSize;

  /// Creates a track size that fits content within the specified [value].
  ///
  /// Represents the formula `max(minimum, min(limit, max-content))`, where minimum represents an auto minimum (which
  /// is often, but not always, equal to a min-content minimum), and limit is the [value]. This is essentially calculated
  /// as the smaller of `minmax(auto, max-content)` and `minmax(auto, limit)`.
  const factory TrackSize.fitContent(Unit value) = _FitContentTrackSize;

  /// A track size representing the largest minimal content contribution of the grid items occupying the grid track.
  static const TrackSize minContent = TrackSize._('min-content');

  /// A track size representing the largest maximal content contribution of the grid items occupying the grid track.
  static const TrackSize maxContent = TrackSize._('max-content');

  /// A track size that is automatically determined.
  /// In most cases, this behaves similarly to minmax(min-content,max-content).
  static const TrackSize auto = TrackSize._('auto');
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

/// Represents a repeated fragment of the track list, allowing a large number of columns that exhibit a recurring
/// pattern to be written in a more compact form.
class TrackRepeat {
  const TrackRepeat._(this.value);

  final String value;

  const TrackRepeat(int times) : value = '$times';

  static const TrackRepeat autoFill = TrackRepeat._('auto-fill');
  static const TrackRepeat autoFit = TrackRepeat._('auto-fit');
}

/// The `gap` CSS property sets the gaps (also called gutters) between rows and columns. This property applies to
/// multi-column, flex, and grid containers.
///
/// Read more: [MDN `gap`](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/gap)
class Gap {
  /// Creates a gap with optional [rowGap] and [columnGap] sizes.
  const Gap({Unit? row, Unit? column}) : rowGap = row, columnGap = column;

  /// Creates a gap with the specified [rowGap] size.
  const Gap.row(Unit value) : rowGap = value, columnGap = null;

  /// Creates a gap with the specified [columnGap] size.
  const Gap.column(Unit value) : rowGap = null, columnGap = value;

  /// Creates a gap with the same size for both [rowGap] and [columnGap].
  const Gap.all(Unit value) : rowGap = value, columnGap = value;

  final Unit? rowGap;
  final Unit? columnGap;

  Map<String, String> get styles {
    if (rowGap != null && rowGap == columnGap) {
      return {'gap': rowGap!.value};
    } else if (rowGap != null && columnGap != null) {
      return {'gap': '${rowGap!.value} ${columnGap!.value}'};
    } else {
      return {
        'row-gap': ?rowGap?.value,
        'column-gap': ?columnGap?.value,
      };
    }
  }
}

/// The CSS `justify-items` property defines the default `justify-self` for all items of the box, giving them all a
/// default way of justifying each box along the appropriate axis.
///
/// Read more: [MDN `justify-items`](https://developer.mozilla.org/en-US/docs/Web/CSS/justify-items)
enum JustifyItems {
  /// The effect of this keyword is dependent of the layout mode we are in:
  ///
  /// - In block-level layouts, the keyword is a synonym of [start].
  /// - In absolutely-positioned layouts, the keyword behaved like [start] on replaced absolutely-positioned boxes, and as
  ///   [stretch] on all other absolutely-positioned boxes.
  /// - In table cell layouts, this keyword has no meaning as this property is ignored.
  /// - In flexbox layouts, this keyword has no meaning as this property is ignored.
  /// - In grid layouts, this keyword leads to a behavior similar to the one of [stretch], except for boxes with an aspect
  ///   ratio or an intrinsic size where it behaves like [start].
  normal('normal'),

  /// If the combined size of the items is less than the size of the alignment container, any auto-sized items have their
  /// size increased equally (not proportionally), while still respecting the constraints imposed by max-height/max-width (or equivalent functionality), so that the combined size exactly fills the alignment container.
  stretch('stretch'),

  /// The items are packed flush to each other toward the center of the alignment container.
  center('center'),

  /// The item is packed flush to each other toward the start edge of the alignment container in the appropriate axis.
  start('start'),

  /// The item is packed flush to each other toward the end edge of the alignment container in the appropriate axis.
  end('end'),

  /// For items that are not children of a flex container, this value is treated like [start].
  flexStart('flex-start'),

  /// For items that are not children of a flex container, this value is treated like [end].
  flexEnd('flex-end'),

  /// The item is packed flush to the edge of the alignment container of the start side of the item, in the appropriate axis.
  selfStart('self-start'),

  /// The item is packed flush to the edge of the alignment container of the end side of the item, in the appropriate axis.
  selfEnd('self-end'),

  /// The items are packed flush to each other toward the left edge of the alignment container. If the property's axis
  /// is not parallel with the inline axis, this value behaves like [start].
  left('left'),

  /// The items are packed flush to each other toward the right edge of the alignment container in the appropriate axis.
  /// If the property's axis is not parallel with the inline axis, this value behaves like [start].
  right('right'),

  /// In the case of anchor-positioned elements, aligns the items to the center of the associated anchor element in the
  /// inline direction.
  anchorCenter('anchor-center'),

  /// Specifies participation in baseline alignment: aligns the alignment baseline of the box's baseline set with the
  /// corresponding baseline in the shared baseline set of all the boxes in its baseline-sharing group.
  baseline('baseline'),

  /// Specifies participation in first-baseline alignment: aligns the alignment baseline of the box's first baseline set
  /// with the corresponding baseline in the shared first baseline set of all the boxes in its baseline-sharing group.
  /// The fallback alignment is [start].
  firstBaseline('first baseline'),

  /// Specifies participation in last-baseline alignment: aligns the alignment baseline of the box's last baseline set
  /// with the corresponding baseline in the shared last baseline set of all the boxes in its baseline-sharing group.
  /// The fallback alignment is [end].
  lastBaseline('last baseline'),

  // Overflow alignment
  safeCenter('safe center'),
  unsafeCenter('unsafe center'),

  // Legacy alignment
  legacyRight('legacy right'),
  legacyLeft('legacy left'),
  legacyCenter('legacy center'),

  // Global values
  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const JustifyItems(this.value);
}
