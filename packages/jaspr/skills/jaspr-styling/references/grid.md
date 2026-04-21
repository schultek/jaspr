# Jaspr CSS Grid Layout

When building 2-dimensional layouts using `Styles()`/`.styles()`, use Jaspr's strong CSS Grid bindings.

## Display
To enable grid layout on a parent, you MUST set the display property:
- `Display? display`: `.grid` or `.inlineGrid`

## Grid Container Properties

Set these properties for the parent container:

**Template Columns/Rows**
Define explicit tracks using `GridTemplate`:
- `GridTemplate? gridTemplate`: `GridTemplate(columns: GridTracks([GridTrack(.fr(1))]), rows: GridTracks([GridTrack(.auto)]))` or `GridTemplate(areas: GridAreas(['header header header', 'sidebar content content', 'footer footer footer']))`
- `GridTracks` can be `.none` or `GridTracks(List<GridTrack>)`
- `GridTrack` can be `GridTrack(TrackSize)`, `.line('my-line')` or `.repeat(TrackRepeat, List<GridTrack>)`
- `TrackSize` can be `TrackSize(100.px)`, `.fr(1.5)`, `.auto`, `.minContent`, `.maxContent`, `.minmax(TrackSize, TrackSize)` or `.fitContent(100.px)`
- `TrackRepeat` can be `TrackRepeat(4)`, `.autoFill` or `.autoFit`

**Auto Rows/Columns (Implicit Grids)**
Define implicit row/column sizing if grid items exceed explicit templates:
- `autoRows: [TrackSize(50.px)]`
- `autoColumns: [TrackSize(100.px)]`

**Grid Gap**
You MUST use the `Gap` class to separate grid items:
- `Gap? gap`: `Gap(row: 10.px, column: 20.px)`, `.row(10.px)`, `.column(20.px)` or `.all(10.px)`

**Alignment**
Align grid tracks within the container and items within their cells:
- `JustifyItems? justifyItems`: `.normal`, `.center`, `.start`, `.end`, `.stretch`, ...
- `AlignItems? alignItems`: `.normal`, `.center`, `.start`, `.end`, `.stretch` or `.baseline`
- `JustifyContent? justifyContent`: `.center`, `.spaceAround`, `.spaceBetween`, `.spaceEvenly`, `.start`, `.end` or `.stretch`
- `AlignContent? alignContent`: `.normal`, `.center`, `.start`, `.end`, `.stretch`, `.spaceAround`, `.spaceBetween` or `.spaceEvenly`

## Grid Item Properties

Apply these properties on children of the Grid container:
- `GridPlacement? gridPlacement`: `.auto`, `.area('my-area')` or `GridPlacement(rowStart: LinePlacement(2), rowEnd: .span(2), columnStart: .auto, columnEnd: .named('my-line'))`
- `JustifySelf? justifySelf`: `.normal`, `.center`, `.start`, `.end`, `.stretch`, ...
- `AlignSelf? alignSelf`: `.normal`, `.center`, `.start`, `.end`, `.stretch`, `baseline`

## Example
```dart
css('.grid-container').styles(
  display: .grid,
  gridTemplate: GridTemplate(
    columns: .repeat(2, [.fr(1)]),
    rows: .repeat(3, [.auto]),
    areas: GridAreas([
      'header header',
      'sidebar content',
      'footer footer',
    ]),
  ),
  gap: .all(20.px),
),
css('.content').styles(
  gridPlacement: .area('content'),
)
```
