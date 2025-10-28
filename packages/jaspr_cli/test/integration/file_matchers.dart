import 'dart:io';

import 'package:test/expect.dart';

final fileExists = TypeMatcher<File>().having((f) => f.existsSync(), 'exists', isTrue);
