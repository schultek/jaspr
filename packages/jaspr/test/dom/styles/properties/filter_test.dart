import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('filter', () {
      test('outputs all properties', () {
        final styles = const Styles(
          filter: Filter.list([
            Filter.blur(),
            Filter.brightness(),
            Filter.contrast(),
            Filter.dropShadow(offsetX: Unit.rem(1), offsetY: Unit.rem(1)),
            Filter.grayscale(),
            Filter.hueRotate(),
            Filter.invert(),
            Filter.opacity(),
            Filter.sepia(),
            Filter.saturate(),
            Filter.url('abc.svg#urltest'),
          ]),
          backdropFilter: Filter.list([
            Filter.blur(Unit.rem(0.1)),
            Filter.brightness(0.2),
            Filter.contrast(0.3),
            Filter.dropShadow(offsetX: Unit.rem(1), offsetY: Unit.rem(1), spread: Unit.rem(0.4), color: Colors.red),
            Filter.grayscale(0.5),
            Filter.hueRotate(Angle.deg(45)),
            Filter.invert(0.6),
            Filter.opacity(0.7),
            Filter.sepia(0.8),
            Filter.saturate(0.9),
            Filter.url('xyz.svg#urltest'),
          ]),
        );

        expect(
          styles.properties,
          equals({
            'filter':
                'blur(0) brightness(1) contrast(1) drop-shadow(1rem 1rem) grayscale(1) hue-rotate(0) invert(1) '
                'opacity(1) sepia(1) saturate(1) url(abc.svg#urltest)',
            'backdrop-filter':
                'blur(0.1rem) brightness(0.2) contrast(0.3) drop-shadow(1rem 1rem 0.4rem red) '
                'grayscale(0.5) hue-rotate(45deg) invert(0.6) opacity(0.7) sepia(0.8) saturate(0.9) '
                'url(xyz.svg#urltest)',
          }),
        );
      });

      test('Filter.list does not allow empty list', () {
        final filter = Filter.list([]);
        expect(() => filter.value, throwsA(predicate((e) => e == 'Filter.list cannot be empty.')));
      });

      test('Filter.list does not allow non-listable members', () {
        for (final val in const <Filter>[
          Filter.none,
          Filter.initial,
          Filter.revert,
          Filter.revertLayer,
          Filter.unset,
        ]) {
          final filter = Filter.list([val]);
          expect(
            () => filter.value,
            throwsA(
              predicate((e) {
                return e == 'Cannot use ${val.value} as a filter list item, only standalone use supported.';
              }),
            ),
          );
        }
      });
    });
  });
}
