class JasprConfig {
  const JasprConfig({
    this.ssr = const JasprSSRConfig(),
    this.usesFlutter = false,
  });

  final JasprSSRConfig ssr;
  final bool usesFlutter;
}

class JasprSSRConfig {
  const JasprSSRConfig({this.enabled = true});

  final bool enabled;
}
