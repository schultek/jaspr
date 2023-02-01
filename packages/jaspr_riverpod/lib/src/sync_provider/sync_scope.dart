part of '../sync_provider.dart';

mixin SyncProviderDependencies on StatelessComponent implements OnFirstBuild {
  @override
  FutureOr<void> onFirstBuild(BuildContext context) async {
    if (!ComponentsBinding.instance!.isClient) {
      await Future.wait(preloadDependencies.map((p) => context.read(p.future)));
    }
  }

  Iterable<SyncProvider> get preloadDependencies;
}

final _syncStateProvider = StateProvider<Map<String, dynamic>>((ref) => {});

mixin SyncScopeMixin on State<ProviderScope> implements SyncStateMixin<ProviderScope, Map<String, dynamic>> {
  @override
  String syncId = 'provider_scope';

  ProviderContainer get container;

  @override
  bool wantsSync() => container.depth == 0;

  @override
  Map<String, dynamic> getState() {
    var syncElements = container.getAllProviderElements().whereType<SyncProviderElement>();
    var map = <String, dynamic>{};
    for (var elem in syncElements) {
      var provider = elem.provider as SyncProvider;
      if (elem.state.isLoading) {
        print("[WARNING] Used SyncProvider without properly preloading the value.\n\n"
            "The unloaded provider is ${provider.id}.");
        continue;
      }
      if (elem.state.hasError) {
        print("[WARNING] SyncProvider had an error when preloading.\n\n"
            "The provider is ${provider.id}.\n"
            "The error is: ${elem.state.error}");
        continue;
      }
      map[provider.id] = elem.state.value;
    }
    return map;
  }

  @override
  void updateState(Map? value) {
    container.read(_syncStateProvider.notifier).update((s) => {...s, ...?value});
  }
}
