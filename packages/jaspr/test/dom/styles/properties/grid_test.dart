@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('grid', () {
      test('tracks', () {
        var tracks = GridTracks.none;
        expect(tracks.value, equals('none'));

        tracks = GridTracks([
          GridTrack(TrackSize.auto),
          GridTrack.line('div'),
          GridTrack.repeat(TrackRepeat(2), [GridTrack(TrackSize.fr(0.2)), GridTrack(TrackSize.maxContent)]),
          GridTrack(TrackSize.minContent),
          GridTrack(TrackSize.fitContent(100.px)),
          GridTrack(TrackSize.minmax(TrackSize(10.px), TrackSize(100.px))),
        ]);
        expect(
          tracks.value,
          equals(
            'auto [div] repeat(2, 0.2fr max-content) min-content '
            'fit-content(100px) minmax(10px, 100px)',
          ),
        );

        expect(
          () => GridTracks([]).value,
          throwsA(predicate((e) => e == 'GridTracks cannot be empty')),
        );
      });

      test('areas', () {
        const areas = GridAreas(['foo', 'bar']);
        expect(areas.value, equals('"foo"\n"bar"'));

        expect(
          () => GridAreas([]).value,
          throwsA(predicate((e) => e == 'GridAreas cannot be empty')),
        );
      });

      test('gap', () {
        var gap = Gap.row(10.px);
        expect(gap.styles, equals({'row-gap': '10px'}));

        gap = Gap.column(20.px);
        expect(gap.styles, equals({'column-gap': '20px'}));

        gap = Gap(row: 10.px, column: 10.px);
        expect(gap.styles, equals({'gap': '10px'}));

        gap = Gap(row: 10.px, column: 20.px);
        expect(gap.styles, equals({'gap': '10px 20px'}));

        gap = Gap.all(10.px);
        expect(gap.styles, equals({'gap': '10px'}));
      });

      test('placement', () {
        var placement = GridPlacement(
          rowStart: LinePlacement.auto,
          rowEnd: LinePlacement.named('test'),
          columnStart: LinePlacement.span(2),
          columnEnd: LinePlacement(3, lineName: 'other'),
        );

        expect(placement.styles, equals({'grid-area': 'auto / span 2 / test / 3 other'}));

        placement = GridPlacement(
          rowStart: LinePlacement.span(3, lineName: 'test'),
          columnEnd: LinePlacement.auto,
        );

        expect(placement.styles, equals({'grid-row': 'span 3 test', 'grid-column-end': 'auto'}));
      });
    });
  });
}
