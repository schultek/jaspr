import 'package:test/test.dart';
import '../lib/server/validation.dart';

void main() {
  group('validateSourceFileName', () {
    test('allows valid filenames', () {
      expect(validateSourceFileName('main.dart'), 'main.dart');
      expect(validateSourceFileName('my_component.dart'), 'my_component.dart');
      expect(validateSourceFileName('counter.dart'), 'counter.dart');
      expect(validateSourceFileName('some_other_file_123.dart'), 'some_other_file_123.dart');
    });

    test('rejects invalid names/traversals', () {
      // Path traversals
      expect(() => validateSourceFileName('../evil.dart'), throwsFormatException);
      expect(() => validateSourceFileName('../../evil.dart'), throwsFormatException);
      expect(() => validateSourceFileName('sub/folder.dart'), throwsFormatException);
      expect(() => validateSourceFileName('sub\\folder.dart'), throwsFormatException);

      // Absolute paths
      expect(() => validateSourceFileName('/etc/passwd'), throwsFormatException);
      expect(() => validateSourceFileName('/tmp/evil.dart'), throwsFormatException);
      expect(() => validateSourceFileName('C:\\Windows\\system32\\cmd.exe'), throwsFormatException);

      // Non-dart files
      expect(() => validateSourceFileName('styles.css'), throwsFormatException);
      expect(() => validateSourceFileName('index.html'), throwsFormatException);

      // Invalid character formats
      expect(() => validateSourceFileName('a-b.dart'), throwsFormatException);
      expect(() => validateSourceFileName('123abc.dart'), throwsFormatException);
      expect(() => validateSourceFileName('abc.dart.js'), throwsFormatException);
      expect(() => validateSourceFileName('.dart'), throwsFormatException);
      expect(() => validateSourceFileName('abc.'), throwsFormatException);
    });
  });
}
