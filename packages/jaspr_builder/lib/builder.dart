import 'package:build/build.dart';

import 'src/apps/apps_builder.dart';
import 'src/apps/islands_builder.dart';
import 'src/imports/analyzing_builder.dart';
import 'src/imports/imports_builder.dart';
import 'src/imports/stubs_builder.dart';

Builder buildIslands(BuilderOptions options) => IslandsBuilder(options);
Builder buildApps(BuilderOptions options) => AppsBuilder(options);

Builder findPlatformImports(BuilderOptions options) => ImportsAnalyzingBuilder(options);
Builder writePlatformImports(BuilderOptions options) => ImportsOutputBuilder(options);
Builder buildPlatformStubs(BuilderOptions options) => ImportsStubsBuilder(options);
