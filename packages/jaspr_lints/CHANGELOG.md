## 0.6.0

- **Breaking** Removed `custom_lint` dependency and migrated to new `analysis_server_plugin`.
  Changes in `analysis_options.yaml` are needed, see [Using plugins](https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server_plugin/doc/using_plugins.md).

## 0.5.1

- Fixed conflicting analysis error for "Sort children last" quick fix.

## 0.5.0

- Extend `prefer_html_methods` lint to also suggest using `text()` and `fragment()` methods, and offer fixes for them.
- Changed `Add styles` assist to create a getter instead of variable.

- Update `analyzer` to `^8.0.0`.
- Update `custom_lint` to `^0.8.0`.

## 0.4.0

- Added 'prefer_styles_getter' lint and fix.
- Update `analyzer_plugin` to `^0.13.0`.

## 0.3.1

- Fix 'add_styles' assist.

## 0.3.0

- Added 'styles_ordering' lint and fix.

## 0.2.1

- Update logo and website links.

## 0.2.0

- Updated `custom_lint` to `^0.7.0`.

## 0.1.2

- Updated sdk constraint to `>=3.5.0 <4.0.0`.
- Fixed setup instructions in README.

## 0.1.1

- Pinned `custom_lint_builder` to 0.6.5.

## 0.1.0

- Initial version.
