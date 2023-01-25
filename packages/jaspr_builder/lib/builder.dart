import 'package:build/build.dart';

import 'src/entrypoint_builder.dart';
import 'src/platform_imports_builder.dart';

Builder buildIslands(BuilderOptions options) => EntrypointBuilder(options);
Builder buildApps(BuilderOptions options) => AppsBuilder(options);

Builder findPlatformImports(BuilderOptions options) => PlatformImportsBuilder(options);
Builder writePlatformImports(BuilderOptions options) => PlatformImportPartsBuilder(options);
Builder buildPlatformStubs(BuilderOptions options) => PlatformStubsBuilder(options);