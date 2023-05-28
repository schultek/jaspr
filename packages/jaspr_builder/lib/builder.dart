import 'package:build/build.dart';

import 'src/client/client_component_builder.dart';
import 'src/client/client_registry_builder.dart';
import 'src/imports/analyzing_builder.dart';
import 'src/imports/imports_builder.dart';
import 'src/imports/stubs_builder.dart';

Builder buildClient(BuilderOptions options) => ClientComponentBuilder(options);
Builder buildRegistry(BuilderOptions options) => ClientRegistryBuilder(options);

Builder findPlatformImports(BuilderOptions options) => ImportsAnalyzingBuilder(options);
Builder writePlatformImports(BuilderOptions options) => ImportsOutputBuilder(options);
Builder buildPlatformStubs(BuilderOptions options) => ImportsStubsBuilder(options);
