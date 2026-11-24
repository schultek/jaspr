/// Tracks the modules that changed since the last successful hot reload.
///
/// Changes accumulate across builds, so a build that starts while a reload is
/// still running does not discard the changes of the previous build.
class ReloadedSources {
  final Map<String, Map<String, Object>> _sources = {};

  /// Records [source] as the latest change of [module].
  void add(String module, Map<String, Object> source) {
    _sources[module] = source;
  }

  /// The entries served to the client as `reloaded_sources.json`.
  List<Map<String, Object>> toJson() => _sources.values.toList();

  /// The entries a reload starting now will deliver.
  ///
  /// Pass the result to [removeDelivered] once the reload has succeeded.
  Map<String, Map<String, Object>> snapshot() => Map.of(_sources);

  /// Removes the entries of [delivered], unless a newer build changed the
  /// module again in the meantime.
  void removeDelivered(Map<String, Map<String, Object>> delivered) {
    delivered.forEach((module, source) {
      if (identical(_sources[module], source)) {
        _sources.remove(module);
      }
    });
  }

  void clear() => _sources.clear();
}
