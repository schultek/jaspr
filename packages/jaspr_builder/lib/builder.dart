import 'package:build/build.dart';

import 'src/entrypoint_builder.dart';
import 'src/jaspr_web_builder.dart';

/// Builder for mocking web-only libraries
JasprWebBuilder buildWebMock(BuilderOptions options) => JasprWebBuilder(options);

Builder buildEntrypoint(BuilderOptions options) => EntrypointBuilder(options);
Builder buildApps(BuilderOptions options) => AppsBuilder(options);