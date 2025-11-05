## Unreleased patch

- Added a new `FileTree` component for rendering file tree structures.
- Enable adding a header based on the current page to `MarkdownOutput`.
- Fixed `TableOfContentsExtension` to correctly find headers in nested elements.
- Update `package:mustache_template` constraint to `^2.0.2`.
  This version adds support for emojis in templates,
  no longer requiring a dependency override.

## 0.4.2

- Fix `FilesystemLoader` not recognizing file changes on Linux.
- Fix the default `PageSource` stripping dots (`.`) from file names when loaded.

## 0.4.1

- `jaspr` upgraded to `0.21.1`
- `jaspr_router` upgraded to `0.7.3`

## 0.4.0

- The `LiquidTemplateEngine` is no longer `const`.
- Fixed resolution of partial files in `LiquidTemplateEngine`.
- Skip adding a `<style>` element for an empty `ContentTheme`.
- Fixed `HtmlParser` to treat html files as fragments.

## 0.3.0

- **Breaking**: `Page.data` now returns a `PageDataMap` with typed getters for
  the maps stored under `page` and `site`.
  It's also `final` now and should be modified using the `Page.apply` method.
- **Breaking**: The `data` parameters in `Page.new` and `MemoryPage.new` have been
  renamed to `initialData` to reflect they don't necessarily specify the final data.
- **Breaking**: `Header` has been moved to `package:jaspr_content/components/header.dart`.
- **Breaking**: `Sidebar` has been moved to `package:jaspr_content/components/sidebar.dart`.

- Added a new `Markdown` component for directly rendering markdown content from a `String`.
- Added support for `sitemap: false` in the page data to exclude pages from the sitemap.
- Ignores files and folders in the content directory starting with `.` (in addition to `_`).
- Require Dart 3.6 or later to match the other Jaspr packages.

- Renamed the `GithubButton` component to `GitHubButton`.
- Fixed `GitHubButton` not linking to the correct repository.
- Renamed the `GithubLoader` route loader to `GitHubLoader`.
- **Breaking:** Made `GitHubPageSource` private.
- Fixed subfolders in `Content` are not recognized on Windows.

## 0.2.0

- **Breaking**: Changed `MemoryPage.builder` to accept a `BuildContext` instead of a `Page` parameter.

- Adding or removing content files will now properly update the routes.
- Support `.yml` in addition to `.yaml` for data files.
- Fixed specifying the `layout` name in frontmatter.
- Fixed `ContentTheme.none` to not apply any styles.
- Fixed typo with `keepSuffixPattern` parameter in `FilesystemLoader` and `GithubLoader`.

## 0.1.1

- `jaspr` upgraded to `0.19.0`
- `jaspr_router` upgraded to `0.7.0`

## 0.1.0

- Initial version.
