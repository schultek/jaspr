import 'package:build/build.dart';

import 'src/client/client_module_builder.dart';
import 'src/client/client_registry_builder.dart';
import 'src/codec/codec_bundle_builder.dart';
import 'src/codec/codec_module_builder.dart';
import 'src/imports/analyzing_builder.dart';
import 'src/imports/imports_builder.dart';
import 'src/imports/stubs_builder.dart';
import 'src/options/jaspr_options_builder.dart';
import 'src/styles/styles_bundle_builder.dart';
import 'src/styles/styles_module_builder.dart';
import 'src/sync/sync_mixins_builder.dart';

Builder buildJasprOptions(BuilderOptions options) => JasprOptionsBuilder(options);

Builder buildClientModule(BuilderOptions options) => ClientModuleBuilder(options);
Builder buildClientRegistry(BuilderOptions options) => ClientRegistryBuilder(options);

Builder buildImportsModule(BuilderOptions options) => ImportsModuleBuilder(options);
Builder buildImportsOutput(BuilderOptions options) => ImportsOutputBuilder(options);
Builder buildPlatformStubs(BuilderOptions options) => ImportsStubsBuilder(options);

Builder buildStylesModule(BuilderOptions options) => StylesModuleBuilder(options);
Builder buildStylesBundle(BuilderOptions options) => StylesBundleBuilder(options);

Builder buildSyncMixins(BuilderOptions options) => SyncMixinsBuilder(options);

Builder buildCodecModule(BuilderOptions options) => CodecModuleBuilder(options);
Builder buildCodecBundle(BuilderOptions options) => CodecBundleBuilder(options);
