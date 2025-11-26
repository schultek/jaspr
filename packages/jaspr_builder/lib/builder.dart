import 'package:build/build.dart';

import 'src/client/client_bundle_builder.dart';
import 'src/client/client_entrypoint_builder.dart';
import 'src/client/client_module_builder.dart';
import 'src/codec/codec_bundle_builder.dart';
import 'src/codec/codec_module_builder.dart';
import 'src/imports/analyzing_builder.dart';
import 'src/imports/imports_builder.dart';
import 'src/imports/stubs_builder.dart';
import 'src/options/client_options_builder.dart';
import 'src/options/server_options_builder.dart';
import 'src/styles/styles_bundle_builder.dart';
import 'src/styles/styles_module_builder.dart';
import 'src/sync/sync_mixins_builder.dart';

Builder buildClientOptions(BuilderOptions options) => ClientOptionsBuilder(options);
Builder buildServerOptions(BuilderOptions options) => ServerOptionsBuilder(options);

Builder buildClientModule(BuilderOptions options) => ClientModuleBuilder(options);
Builder buildClientsBundle(BuilderOptions options) => ClientsBundleBuilder(options);
Builder buildClientEntrypoint(BuilderOptions options) => ClientEntrypointBuilder(options);

Builder buildImportsModule(BuilderOptions options) => ImportsModuleBuilder(options);
Builder buildImportsOutput(BuilderOptions options) => ImportsOutputBuilder(options);
Builder buildPlatformStubs(BuilderOptions options) => ImportsStubsBuilder(options);

Builder buildStylesModule(BuilderOptions options) => StylesModuleBuilder(options);
Builder buildStylesBundle(BuilderOptions options) => StylesBundleBuilder(options);

Builder buildSyncMixins(BuilderOptions options) => SyncMixinsBuilder(options);

Builder buildCodecModule(BuilderOptions options) => CodecModuleBuilder(options);
Builder buildCodecBundle(BuilderOptions options) => CodecBundleBuilder(options);
