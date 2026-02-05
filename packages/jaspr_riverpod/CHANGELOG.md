## 0.4.4

- Fix `.syncWith` incorrectly applying codec when decoding values.

## 0.4.3

- Fix compilation errors with `riverpod` versions `^3.1.0`

## 0.4.2

- `jaspr` upgraded to `0.22.0`

## 0.4.1

- Fix compilation errors with `riverpod` versions `^3.0.2`.

## 0.4.0

- Upgrade `riverpod` to `^3.0.0`

- **Breaking**: Removed `SyncProvider`. Migrate to `ProviderScope(sync: [...])`.

- Added `sync` option to `ProviderScope`, which allows to specify providers that should sync its value to the client using:

  ```dart
  ProviderScope(
    sync: [
      myProvider.syncWith('my-unique-id'),
    ],
    child: ...
  )
  ```

  The `.syncWith` extension is available on `Provider`, `FutureProvider`, `StreamProvider`, `StateProvider`, `NotifierProvider` and `AsyncNotifierProvider`.

  For `FutureProvider`, `StreamProvider` and `AsyncNotifierProvider` this also awaits the future during pre-rendering before building the child component.

- **Breaking**: Renamed `context.subscribe()` to `context.listenManual()` to be consistent with `WidgetRef`.

## 0.3.23

- `jaspr` upgraded to `0.21.1`
- `jaspr_test` upgraded to `0.21.1`

## 0.3.22

- `jaspr` upgraded to `0.21.0`
- `jaspr_test` upgraded to `0.21.0`

## 0.3.21

- `jaspr` upgraded to `0.20.0`

## 0.3.20

- `jaspr` upgraded to `0.19.0`

## 0.3.19

- `jaspr` upgraded to `0.18.0`

## 0.3.18

- Update logo and website links.

## 0.3.17

- `jaspr` upgraded to `0.17.0`

## 0.3.16

- Upgrade `riverpod` to `^2.6.0`

## 0.3.15

- `jaspr` upgraded to `0.16.0`

## 0.3.14

- `jaspr` upgraded to `0.15.0`

## 0.3.13

- `jaspr` upgraded to `0.14.0`

## 0.3.12

- `jaspr` upgraded to `0.13.0`

## 0.3.11

- `jaspr` upgraded to `0.12.0`

## 0.3.10

- Fixed bug with .autoDispose providers.

## 0.3.9

- `jaspr` upgraded to `0.10.0`

## 0.3.8

- Upgrade `riverpod` to `v2.4.8`
- Update `jaspr_riverpod`'s dependency on `riverpod`'s `vsyncOverride` to `flutterVsyncs`

## 0.3.7

- Fixed bug with SyncProvider.

## 0.3.6

- `jaspr` upgraded to `0.9.0`

## 0.3.5

- `jaspr` upgraded to `0.8.0`

## 0.3.4

- `jaspr` upgraded to `0.7.0`

## 0.3.3

- `jaspr` upgraded to `0.6.0`

## 0.3.2

- `jaspr` upgraded to `0.5.0`

## 0.3.1

- Added `ref.binding` to access the component binding inside providers.

## 0.3.0

- Update riverpod to `v2.3.2`

## 0.2.0

- Update riverpod to `v2.1.3`
- Update jaspr to `v0.2.0`

## 0.1.0

- Initial release with `riverpod: 2.0.2`
