import 'package:jaspr/jaspr.dart';
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
          GridTrack.repeat(TrackRepeat(2), [
            GridTrack(TrackSize.fr(0.2)),
            GridTrack(TrackSize.maxContent),
          ]),
          GridTrack(TrackSize.minContent),
          GridTrack(TrackSize.fitContent(100.px)),
          GridTrack(TrackSize.minmax(TrackSize(10.px), TrackSize(100.px))),
        ]);
        expect(
          tracks.value,
          equals('auto [div] repeat(2, 0.2fr max-content) min-content '
              'fit-content(100px) minmax(10px, 100px)'),
        );
      });

      test('gap', () {
        var gap = GridGap(row: 10.px);
        expect(gap.styles, equals({'row-gap': '10px'}));

        gap = GridGap(row: 10.px, column: 10.px);
        expect(gap.styles, equals({'gap': '10px'}));

        gap = GridGap(row: 10.px, column: 20.px);
        expect(gap.styles, equals({'gap': '10px 20px'}));

        gap = GridGap.all(10.px);
        expect(gap.styles, equals({'gap': '10px'}));
      });
    });
  });
}
