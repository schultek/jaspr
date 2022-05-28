# 🌊 Riverpod for Jaspr

**TLDR: Differences to flutter_riverpod**

- No ConsumerComponent, just use `context.read` / `context.watch`
- Additional `.onSync()` and `.onPreload()` available on a providers `ref`.

**Why context extensions instead of ConsumerComponent?**

`context.watch` is not feasible in `flutter_riverpod` as explained here:
[github.com/rrousselGit/riverpod/issues/134](https://github.com/rrousselGit/riverpod/issues/134)

There are long standing bugs (or missing features depending on how you view it) in flutter
with `InheritedWidget` that make it impossible for `context.watch` to work properly (Mainly
here: [github.com/flutter/flutter/issues/62861](https://github.com/flutter/flutter/issues/62861)).
As `jaspr` is basically a complete rewrite of flutters core framework, I went ahead and fixed
these bugs and thereby making `context.watch` feasible again.

# 👀 Reading and Watching Providers

Read and watch a provider like this:

```dart
final countProvider = StateProvider((ref) => 0);

class Counter extends StatelessComponent {
  Iterable<Component> build(BuildContext context) sync* {
    var value = context.watch(countProvider);
    
    yield Text('Value is $value');
    yield DomComponent(
      tag: 'button',
      events: {'click': (e) => context.read(countProvider.notifier).state++},
      child: Text('Increase'),
    );
  }
}
```