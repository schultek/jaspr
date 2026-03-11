# Jaspr Box Model & Interaction

When managing element structure, positioning, backgrounds, and user interaction, use the following `Styles()`/`.styles()` properties:

*(Note: For Margin, Padding, Width, Height, Borders, and Radius, see `sizing.md`)*

## Positioning
- `Position? position`: `.absolute()`, `.relative()`, `.fixed()`, `.sticky()`, `.static`
  - For offsets, use the named arguments inside the `Position` constructors: `.absolute(top: 10.px, left: 10.px)`
- `ZIndex? zIndex`: `ZIndex(10)` or `.auto`

## Backgrounds
- `Color? backgroundColor`: `Colors.blue`, ...
- `ImageStyle? backgroundImage`: `.url('image.png')`
- `BackgroundOrigin? backgroundOrigin`: `.contentBox` or `.paddingBox`, `.borderBox`
- `BackgroundPosition? backgroundPosition`: `.center` or `BackgroundPosition(offsetX: 10.px, offsetY: 10.px, alignX: .center, alignY: .top)`
- `BackgroundAttachment? backgroundAttachment`: `.fixed` or `.scroll`, `.local`
- `BackgroundRepeat? backgroundRepeat`: `.repeat` or `.noRepeat`, `.repeatX`, `.repeatY`, `.space`, `.round`
- `BackgroundSize? backgroundSize`: `.cover`, `.contain`
- `BackgroundClip? backgroundClip`: `.text` or `.borderBox`, `.paddingBox`, `.contentBox`

## Overflow & Visibility
- `Overflow? overflow`: `.hidden`, `.scroll`, `.auto`, `.visible` or `.only(x: .scroll, y: .hidden)`
- `Visibility? visibility`: `.hidden`, `.visible` or `.collapse`
- `double? opacity`: `0.5` *(double from 0.0 to 1.0)*

## Transforms
Manipulate the element's coordinate space natively:
- `Transform? transform`: `.translate(x: 10.px, y: 10.px)`, `.scale(1.5)`, `.rotate(45.deg)`, `.combine([.translate(x: 10.px), .rotate(45.deg)])`

## Filters & Shadows
- `BoxShadow? shadow`: `BoxShadow(offsetX: 2.px, offsetY: 2.px, blur: 4.px, spread: 1.px, color: Colors.black)`
- `Filter? filter`: `.blur(5.px)`, `.dropShadow(...)`, `.brightness(150)`, `.grayscale()`, `.opacity(0.5)`, `.url('filter.svg')`
- `Filter? backdropFilter`: `.blur(10.px)`, ...

## Interaction
Control how the user interacts with the element:
- `Cursor? cursor`: `.pointer`, `.defaultCursor`, `.text`, `.notAllowed`, ...
- `UserSelect? userSelect`: `.none`, `.text`, `.all`, `.auto`
- `PointerEvents? pointerEvents`: `.none`, `.auto`, ...
