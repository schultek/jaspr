import 'dart:io';

import 'package:native_toolchain_rust/native_toolchain_rust.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  try {
    await build(args, (BuildConfig buildConfig, BuildOutput output) async {
      final builder = RustBuilder(
        package: 'jaspr_og',
        cratePath: 'resvg/crates/c-api',
        buildConfig: buildConfig,
      );
      await builder.run(output: output);
    });
  } catch (e) {
    // ignore: avoid_print
    print(e);
    exit(1);
  }
}