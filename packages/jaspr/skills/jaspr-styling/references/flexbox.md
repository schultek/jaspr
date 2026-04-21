# Jaspr Flexbox

When configuring layout with `Styles()`/`.styles()`, Jaspr provides strong typing for flexbox and flex-item properties. 

## Display
To enable flexbox, you MUST set the display property:
- `Display? display`: `.flex` or `.inlineFlex`

## Flexbox Container Properties
Set these properties for the parent container:
- `FlexDirection? flexDirection`: `.row`, `.column`, `.rowReverse` or `.columnReverse`
- `JustifyContent? justifyContent`: `.center`, `.spaceBetween`, `.spaceAround`, `.spaceEvenly`, `.start` or `.end`
- `AlignItems? alignItems`: `.center`, `.stretch`, `.start`, `.end` or `.baseline`
- `AlignContent? alignContent`: `.center`, `.spaceAround`, `.spaceBetween`, `.stretch`, `.start` or `.end`
- `FlexWrap? flexWrap`: `.wrap`, `.nowrap` or `.wrapReverse`
- `Gap? gap`: `.all(10.px)`

## Flex Item Properties
Apply these styles to the children of a Flexbox container:
- `Flex? flex`: `.auto`, `.none`, `.grow(1)`, `.shrink(1)`, `.basis(10.px)` or `Flex(grow: 1, shrink: 1, basis: 10.px)`
- `int? order`: `1`
- `AlignSelf? alignSelf`: `.center`, `.stretch`, `.start`, `.end` or `.baseline`

## Example
```dart
css('.container').styles(
  display: .flex,
  flexDirection: .row,
  justifyContent: .spaceBetween,
  alignItems: .center,
),
css('.container > .item').styles(
  flex: .grow(1),
  alignSelf: .stretch,
)
```
