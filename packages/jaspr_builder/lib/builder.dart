import 'package:build/build.dart';

import 'src/entrypoint_builder.dart';
import 'src/islands_builder.dart';
import 'src/jaspr_web_builder.dart';

/// Builder for mocking web-only libraries
JasprWebBuilder buildWebMock(BuilderOptions options) => JasprWebBuilder(options);

/// Builder for a single island component
Builder buildIsland(BuilderOptions options) => IslandBuilder(options);

/// Builder for the registry of all island components
Builder buildIslandsApp(BuilderOptions options) => IslandsAppBuilder(options);

Builder buildEntrypoint(BuilderOptions options) => EntrypointBuilder(options);
Builder buildApps(BuilderOptions options) => AppsBuilder(options);