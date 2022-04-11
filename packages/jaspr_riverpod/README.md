# jaspr_riverpod

Riverpod for jaspr

### Differences to flutter_riverpod

- No Consumer, just use `context.read` / `context.watch`

- Additional `.onSync()` and `.onPreload()` available on a providers `ref`.
