# jaspr_riverpod

Riverpod for jaspr

## Differences to flutter_riverpod

- No Consumer, just use `context.read` / `context.watch`
- Additional `.onSync()` and `.onPreload()` available on a providers `ref`.

## Why context extensions instead of Consumer

`context.watch` is not feasible in `flutter_riverpod` as explained here: 
[github.com/rrousselGit/riverpod/issues/134](https://github.com/rrousselGit/riverpod/issues/134)

There are long standing bugs (or missing features depending on how you view it) in flutter 
with `InheritedWidget` that make it impossible for `context.watch` to work properly (Mainly 
here: [github.com/flutter/flutter/issues/62861](https://github.com/flutter/flutter/issues/62861)). 
As `jaspr` is basically a complete rewrite of flutters core framework, I went ahead and fixed 
these bugs and thereby making `context.watch` feasible again.