@TestOn('vm')
library;

import 'package:jaspr/src/dom/validator.dart';
import 'package:test/test.dart';

void main() {
  group('DomValidator', () {
    late DomValidator validator;

    setUp(() {
      validator = DomValidator();
    });

    group('validateElementName', () {
      test('accepts valid element names', () {
        expect(() => validator.validateElementName('div'), returnsNormally);
        expect(() => validator.validateElementName('custom-element'), returnsNormally);
        expect(() => validator.validateElementName('h1'), returnsNormally);
      });

      test('throws on invalid element names', () {
        expect(() => validator.validateElementName('1div'), throwsArgumentError);
        expect(() => validator.validateElementName('-element'), throwsArgumentError);
        expect(() => validator.validateElementName('div!'), throwsArgumentError);
      });
    });

    group('validateAttributeName', () {
      test('accepts valid attribute names', () {
        expect(() => validator.validateAttributeName('id'), returnsNormally);
        expect(() => validator.validateAttributeName('data-test'), returnsNormally);
        expect(() => validator.validateAttributeName('aria-label'), returnsNormally);
        expect(() => validator.validateAttributeName(':class'), returnsNormally);
        expect(() => validator.validateAttributeName('@scroll.window'), returnsNormally);
      });

      test('throws on invalid attribute names', () {
        expect(() => validator.validateAttributeName('1id'), throwsArgumentError);
        expect(() => validator.validateAttributeName('-test'), throwsArgumentError);
        expect(() => validator.validateAttributeName('data!'), throwsArgumentError);
      });
    });

    group('isSelfClosing', () {
      test('returns true for self-closing elements', () {
        expect(validator.isSelfClosing('img'), isTrue);
        expect(validator.isSelfClosing('br'), isTrue);
        expect(validator.isSelfClosing('input'), isTrue);
      });

      test('returns false for non-self-closing elements', () {
        expect(validator.isSelfClosing('div'), isFalse);
        expect(validator.isSelfClosing('span'), isFalse);
        expect(validator.isSelfClosing('p'), isFalse);
      });
    });

    group('hasStrictWhitespace', () {
      test('returns true for elements with strict whitespace', () {
        expect(validator.hasStrictWhitespace('p'), isTrue);
        expect(validator.hasStrictWhitespace('h1'), isTrue);
        expect(validator.hasStrictWhitespace('label'), isTrue);
      });

      test('returns false for elements without strict whitespace', () {
        expect(validator.hasStrictWhitespace('div'), isFalse);
        expect(validator.hasStrictWhitespace('span'), isFalse);
      });
    });

    group('hasStrictFormatting', () {
      test('returns true for elements with strict formatting', () {
        expect(validator.hasStrictFormatting('pre'), isTrue);
        expect(validator.hasStrictFormatting('span'), isTrue);
      });

      test('returns false for elements without strict formatting', () {
        expect(validator.hasStrictFormatting('div'), isFalse);
        expect(validator.hasStrictFormatting('p'), isFalse);
      });
    });
  });
}
