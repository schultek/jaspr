import 'package:build/build.dart';

import 'src/islands_builder.dart';
import 'src/jaspr_web_builder.dart';

/// Entry point for the builder
JasprWebBuilder buildWebFake(BuilderOptions options) => JasprWebBuilder(options);

Builder buildIsland(BuilderOptions options) => IslandBuilder(options);

Builder buildIslandsApp(BuilderOptions options) => IslandsAppBuilder(options);
