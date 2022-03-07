# jaspr_riverpod

Riverpod for jaspr


- ChangeNotifierProvider not available since ChangeNotifier is not in the framework yet

- No Consumer, just use `context.read` / `context.watch`

- Additional `.onSync()` and `.onPreload()` available on a providers `ref`.
