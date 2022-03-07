part of framework;

class _SyncRef<T> {
  final Ref ref;
  final String id;
  final void Function(T? value) onUpdate;
  final T Function() onSave;
  final Codec<T, dynamic> codec;

  _SyncRef(this.ref, this.id, this.onUpdate, this.onSave, this.codec);

  dynamic _onSave() {
    return codec.encode(onSave());
  }

  void _onUpdate(dynamic value) {
    onUpdate(value != null ? codec.decode(value) : null);
  }
}

extension SyncRef on Ref {
  T? onSync<T>({
    required String id,
    required void Function(T? value) onUpdate,
    required T Function() onSave,
    Codec<T, dynamic>? codec,
  }) {
    var notifier = watch(_syncProvider.notifier);
    var sync = _SyncRef<T>(this, id, onUpdate, onSave, codec ?? CastCodec());
    return notifier._register<T>(sync);
  }

  void onPreload(Future<void> Function() fn) {
    watch(_syncProvider.notifier)._registerPreload(fn);
  }
}

mixin PreloadProviderDependencies on StatelessComponent implements OnFirstBuild {
  @override
  FutureOr<void> onFirstBuild(BuildContext context) async {
    if (!ComponentsBinding.instance!.isClient) {
      await Future.wait(dependencies.map((p) => context.preload(p)));
    }
  }

  Iterable<ProviderBase> get dependencies;
}
