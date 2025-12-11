## 0.4.10

- `jaspr` upgraded to `0.22.0`

## 0.4.9

- `jaspr` upgraded to `0.21.1`

## 0.4.8

- `jaspr` upgraded to `0.21.0`

## 0.4.7

- `jaspr` upgraded to `0.20.0`

## 0.4.6

- `jaspr` upgraded to `0.19.0`

## 0.4.5

- `jaspr` upgraded to `0.18.0`

## 0.4.4

- Update logo and website links.

## 0.4.3

- `jaspr` upgraded to `0.17.0`

## 0.4.2

- Fixed layout bug of embedded flutter view.

## 0.4.1

- Fixed flutter embedding on mobile to always use canvaskit renderer.

## 0.4.0

- **BREAKING** Migrated to `package:web`.
- **BREAKING** Added support for multi-view embedding. This allows you to use `FlutterEmbedView` multiple times across
  the website and add or remove views at any time.

- Improved internals to use deferred imports for all imported flutter libraries.
- Added `FlutterEmbedView.preload()` function to manually trigger the preload of all deferred libraries before rendering
  a Flutter view.
- Added `FlutterEmbedView.deferred()` constructor as an easy way to work with deferred imports of widgets.

- Updated sdk constraints of flutter to `>=3.24.0 <4.0.0` and dart to `>=3.5.0 <4.0.0`.

## 0.3.4

- `jaspr` upgraded to `0.15.0`

## 0.3.3

- `jaspr` upgraded to `0.14.0`

## 0.3.2

- `jaspr` upgraded to `0.13.0`

## 0.3.1

- `jaspr` upgraded to `0.12.0`

## 0.3.0

- Changed internal bootstrapping of flutter engine.
- Requires a peer dependency of `jaspr_web_compilers >= 4.0.9`.

## 0.2.0

- **BREAKING** Changed `FlutterEmbedView.classes` type from `List<String>` to `String`.

## 0.1.4

- Support `flutter >= 3.13.0`

## 0.1.3

- `jaspr` upgraded to `0.9.0`

## 0.1.2

- `jaspr` upgraded to `0.8.0`

## 0.1.1

- `jaspr` upgraded to `0.7.0`

## 0.1.0

- Initial release.
