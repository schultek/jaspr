## Unreleased patch

- Added support for `sitemap: false` in the page data to exclude pages from the sitemap.
- Ignores files and folders in the content directory starting with `.` (in addition to `_`).

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
